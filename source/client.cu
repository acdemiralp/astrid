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
    socket.connect(address_);

    while (alive_)
    {
      request request;
      on_send(request_cache_, request);

      auto string = request.SerializeAsString();
      zmq::message_t message(string.begin(), string.end());
      socket .send   (message);
      message.rebuild();
      socket .recv   (message);

      image image;
      image.ParseFromArray(message.data(), static_cast<std::int32_t>(message.size()));
      on_receive(image);
    }
  });
}
client::~client()
{
  alive_ = false;
  future_.get();
}
}
