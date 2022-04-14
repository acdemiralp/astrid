#include <astrid/client.hpp>

#include <stdexcept>

namespace ast
{
client::client (const std::string& address, const std::int32_t timeout_ms) : address_("tcp://" + address)
{
  zmq::monitor_t monitor;
  monitor.init   (socket_, "inproc://monitor", ZMQ_EVENT_CONNECTED);
  socket_.connect(address_);
  if (!monitor.check_event(timeout_ms))
    throw std::runtime_error("Server unreachable.");
  
  future_ = std::async(std::launch::async, [&]
  {
    while (alive_)
    {
      if (request_auto_ || request_once_)
      {
        if (request_once_)
          request_once_ = false;
        
        emit on_send_request();
        std::this_thread::sleep_for(std::chrono::milliseconds(1)); // Horrid.

        auto string = request_data_.SerializeAsString();

        zmq::message_t message(string.data(), string.size());
        socket_ .send   (message);
        message.rebuild();
        socket_ .recv   (message);

        response_data_.ParseFromArray(message.data(), static_cast<std::int32_t>(message.size()));

        emit on_receive_response();
      }
    }

    emit on_finalize();
  });
}
client::~client()
{
  alive_ = false;
  future_.get();
}
}