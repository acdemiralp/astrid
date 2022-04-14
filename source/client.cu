#include <astrid/client.hpp>

#include <cstdint>

#include <zmq.hpp>

namespace ast
{
client::client (const std::string& address) : address_("tcp://" + address), alive_(true)
{
  future_ = std::async(std::launch::async, [&]
  {
    zmq::context_t context {1};
    zmq::socket_t  socket  {context, ZMQ_PAIR};
    zmq::message_t message;

    socket.connect(address_);
    while (alive_)
    {
      if (request_auto_ || request_once_)
      {
        if (request_once_)
          request_once_ = false;
        
        on_send_request();

        auto string = request_data_.SerializeAsString();

        message.rebuild(string.data(), string.size());
        socket .send   (message);
        message.rebuild();
        socket .recv   (message);

        response_data_.ParseFromArray(message.data(), static_cast<std::int32_t>(message.size()));

        on_receive_response();
      }
    }
  });
}
client::~client()
{
  alive_ = false;
  future_.get();
}
}