#pragma once

#include <atomic>
#include <future>
#include <string>

#include <sigslot/signal.hpp>

#include <request.pb.h>
#include <image.pb.h>

namespace ast
{
class window;

class client
{
public:
  explicit client  (const std::string& address = "127.0.0.1:3000");
  client           (const client&  that) = delete;
  client           (      client&& temp) = delete;
  virtual ~client  ();
  client& operator=(const client&  that) = delete;
  client& operator=(      client&& temp) = delete;

  sigslot::signal<request&, request&> on_send   ;
  sigslot::signal<const image&>       on_receive;
  
protected:
  std::string       address_      ;
  std::atomic<bool> alive_        ;
  std::future<void> future_       ;
  request           request_cache_;
};
}