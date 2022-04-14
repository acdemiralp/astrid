#include <astrid/window.hpp>

#include <QString>
#include <QInputDialog>
#include <QLineEdit>

#include <astrid/make_local_server.hpp>

namespace ast
{
window::window(QWidget* parent) : QMainWindow(parent), ui_(new Ui::main_window)
{
  ui_->setupUi(this);
  
  setWindowTitle("Astrid");
  resize        (1024, 600);
  
  connect(ui_->action_connect_local , &QAction::triggered, this, [&] 
  {
    statusBar()->showMessage("Connecting to local server.");
    make_local_server();
    client_ = std::make_unique<client>();
  });
  connect(ui_->action_connect_remote, &QAction::triggered, this, [&] 
  {
    bool confirm;
    const auto address = QInputDialog::getText(
      this, 
      "Connect", 
      "Enter the IP address and port of the Astrid server:",
      QLineEdit::Normal,
      "127.0.0.1:3000",
      &confirm);

    if (confirm)
    {
      statusBar()->showMessage("Connecting to remote server " + address + ".");
      client_ = std::make_unique<client>(address.toStdString());
    }
  });
  connect(ui_->action_disconnect    , &QAction::triggered, this, [&] 
  {
    statusBar()->showMessage("Disconnecting from server.");
    client_.reset();
  });
  connect(ui_->action_exit          , &QAction::triggered, this, [&] 
  {
    std::exit(0);
  });
  
  make_local_server();
  client_ = std::make_unique<client>();
  connect(client_.get(), &client::on_receive_response, this, [&]()
  {
    ui_->image->setPixmap(QPixmap::fromImage(QImage(
      reinterpret_cast<const unsigned char*>(client_->response_data().data().c_str()),
      client_->response_data().size().x(),
      client_->response_data().size().y(),
      QImage::Format_RGB888)));
  });
  client_->make_request();

  // TODO: Program toolbox elements, render button.
  
  statusBar()->showMessage("Initialization successful.");
}
}