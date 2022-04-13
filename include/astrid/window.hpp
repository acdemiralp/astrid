#pragma once

#include <memory>
#include <string>

#include <QMainWindow>

#include <astrid/connection_state.hpp>
#include <ui_main_window.h>

namespace ast
{
class window : public QMainWindow
{
  Q_OBJECT

public:
  explicit window(QWidget* parent = nullptr);

private:
  std::unique_ptr<Ui::main_window> ui_;

  QString          server_address_;
  connection_state connection_state_ = connection_state::disconnected;
};
}