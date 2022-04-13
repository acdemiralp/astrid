#include <astrid/window.hpp>

#include <QInputDialog>
#include <QLineEdit>

namespace ast
{
window::window(QWidget* parent) : QMainWindow(parent), ui_(new Ui::main_window)
{
  ui_->setupUi(this);
  
  setWindowTitle("Astrid");
  resize        (1024, 600);
  
  connect(ui_->action_connect   , &QAction::triggered, this, [&] ()
  {
    bool ok;
    const auto result = QInputDialog::getText(
      this, 
      "Connect", 
      "Enter the IP address and port of the Astrid server:",
      QLineEdit::Normal,
      "127.0.0.1:3000",
      &ok);

    if (ok)
    {
      statusBar()->showMessage("Connecting to " + result + ".");

      server_address_ = result;
      // TODO: Attempt to connect to server_address_.
    }
  });
  connect(ui_->action_disconnect, &QAction::triggered, this, [&] ()
  {
    statusBar()->showMessage("Disconnecting from " + server_address_ + ".");

    // TODO: Disconnect.
  });
  connect(ui_->action_exit      , &QAction::triggered, this, [&] ()
  {
    std::exit(0);
  });

  // TODO.
  
  statusBar()->showMessage("Initialization successful.");
}
}