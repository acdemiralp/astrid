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
  ::image   image  ;

  while (!request.terminate())
  {
    if (communicator.rank() == 0)
    {
      zmq::message_t received;
      auto recv_result = socket.recv(received, zmq::recv_flags::none);
      request.ParseFromArray(received.data(), static_cast<std::int32_t>(received.size()));
    }

    // TODO: Propagate the request to other ranks and render the image.

    if (communicator.rank() == 0)
    {
      auto string      = image.SerializeAsString();
      zmq::message_t sent(string.begin(), string.end());
      auto send_result = socket.send(sent, zmq::send_flags::none);
      std::cout << "Sent image with size: " << image.size().x() << " " << image.size().y() << "\n";
    }
  }

  return 0;
}
}
