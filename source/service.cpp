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
  const std::string address = "tcp://*:3000"; // TODO: Retrieve port from arguments.

  zmq::context_t context(1);
  zmq::socket_t  socket (context, ZMQ_PAIR);
  socket.bind(address);
  std::cout << "Service running at: " << address << "\n";
  
  ::request request;
  ::image   image  ;

  while (true)
  {
    zmq::message_t received;
    auto recv_result = socket.recv(received, zmq::recv_flags::none);
    request.ParseFromArray(received.data(), static_cast<std::int32_t>(received.size()));

    // TODO: Create the image based on the request.

    auto string      = image.SerializeAsString();
    zmq::message_t sent(string.begin(), string.end());
    auto send_result = socket.send(sent, zmq::send_flags::none);
    std::cout << "Sent image with size: " << image.size().x() << " " << image.size().y() << "\n";
  }

  return 0;
}
}
