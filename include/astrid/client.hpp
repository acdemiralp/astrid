#pragma once

#include <atomic>
#include <future>
#include <string>

#include <QObject>

#include <request.pb.h>
#include <image.pb.h>

namespace ast
{
class client : public QObject
{
  Q_OBJECT

public:
  explicit client  (const std::string& address = "127.0.0.1:3000");
  client           (const client&  that) = delete;
  client           (      client&& temp) = delete;
  virtual ~client  ();
  client& operator=(const client&  that) = delete;
  client& operator=(      client&& temp) = delete;
  
  void         make_request       ()
  {
    request_once_ = true;
  }
  void         set_auto_request   (const bool auto_request)
  {
    request_auto_ = auto_request;
  }

  request&     request_data       ()
  {
    return request_data_;
  }
  const image& response_data      () const
  {
    return response_data_;
  }

signals:
  void         on_send_request    ();
  void         on_receive_response();
  
protected:
  std::string       address_      ;
  std::future<void> future_       ;
  std::atomic<bool> alive_        ;
  std::atomic<bool> request_once_ ;
  std::atomic<bool> request_auto_ ;
  ::request         request_data_ ;
  ::image           response_data_;
};
}