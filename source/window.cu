#include <astrid/window.hpp>


window::window(QWidget* parent) : QMainWindow(parent), ui_(new Ui::main_window)
{
  ui_->setupUi(this);
  
  setWindowTitle("Astrid");
  resize        (1024, 600);

  // TODO.
}
