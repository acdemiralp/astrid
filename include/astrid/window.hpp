#pragma once

#include <memory>
#include <unordered_map>

#include <astray/api.hpp>
#include <QMainWindow>
#include <QTimer>
#include <QWidget>

#include <astrid/client.hpp>
#include <ui_main_window.h>

namespace ast
{
class window : public QMainWindow
{
  Q_OBJECT

public:
  explicit window(QWidget* parent = nullptr);

  void keyPressEvent  (QKeyEvent* event) override;
  void keyReleaseEvent(QKeyEvent* event) override;

private:
  void set_ui_state     (bool connected) const;

  void create_client    (const std::string& address = "127.0.0.1:3000");
  void destroy_client   ();

  void fill_request_data(proto::request& request);

  std::unique_ptr<Ui::main_window>  ui_        ;
  std::unique_ptr<client>           client_    ;
  image<vector3<std::uint8_t>>      background_;

  std::unique_ptr<QTimer>           timer_     ;
  std::unordered_map<Qt::Key, bool> key_map_   ;
};
}