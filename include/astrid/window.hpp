#pragma once

#include <memory>

#include <QMainWindow>
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

private:
  void make_client(const std::string& address = "127.0.0.1:3000");

  std::unique_ptr<Ui::main_window> ui_    ;
  std::unique_ptr<client>          client_;
};
}