#include <astrid/service.hpp>

#include <iostream>
#include <string>

#include <astray/api.hpp>
#include <zmq.hpp>

#include <image.pb.h>
#include <request.pb.h>

namespace ast
{
std::int32_t service::run(std::int32_t argc, char** argv) 
{
  mpi::environment  environment ;
  mpi::communicator communicator;

  zmq::context_t    context(1);
  zmq::socket_t     socket (context, ZMQ_PAIR);
  if (communicator.rank() == 0)
  {
    const std::string address = "tcp://*:3000"; // TODO: Retrieve port from arguments.
    socket.bind(address);
    std::cout << "Service running at: " << address << "\n";
  }
  
  ::request request;
  while (!request.terminate())
  {
    std::int32_t              size;
    std::vector<std::uint8_t> data;

    if (communicator.rank() == 0)
    {
      zmq::message_t message;
      socket.recv(message, zmq::recv_flags::none);

      size = static_cast<std::int32_t>(message.size());
      data.resize(message.size());
      std::copy_n(static_cast<std::uint8_t*>(message.data()), message.size(), data.begin());
    }
    
    communicator.bcast(&size      , 1   , mpi::data_type(MPI_INT ));
    data.resize(size);
    communicator.bcast(data.data(), size, mpi::data_type(MPI_BYTE));
    request.ParseFromArray(data.data(), static_cast<std::int32_t>(data.size()));
    
    // TODO: Render the image according to the request.
    image<float> result;

    if (communicator.rank() == 0)
    {
      ::image image;
      image.mutable_data()->assign(result.data.begin(), result.data.end());
      image.mutable_size()->set_x (result.size[0]);
      image.mutable_size()->set_y (result.size[1]);
      auto string = image.SerializeAsString();

      zmq::message_t message(string.begin(), string.end());
      socket.send(message, zmq::send_flags::none);
      std::cout << "Sent image with size: " << image.size().x() << " " << image.size().y() << "\n";
    }
  }

  return 0;
}
}