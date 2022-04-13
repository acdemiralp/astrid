#pragma once

#include <memory>

#include <QMainWindow>

#include <ui_main_window.h>

class window : public QMainWindow
{
  Q_OBJECT

public:
  explicit window(QWidget* parent = nullptr);

private:
  std::unique_ptr<Ui::main_window> ui_;
};