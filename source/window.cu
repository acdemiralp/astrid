#include <astrid/window.hpp>

#include <QString>
#include <QInputDialog>
#include <QLineEdit>

namespace ast
{
window::window(QWidget* parent) : QMainWindow(parent), ui_(new Ui::main_window)
{
  ui_->setupUi(this);
  
  setWindowTitle("Astrid");
  resize        (1024, 600);
  
  connect(ui_->action_connect_local , &QAction::triggered       , this, [&] 
  {
    make_client();
  });
  connect(ui_->action_connect_remote, &QAction::triggered       , this, [&] 
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
      make_client(address.toStdString());
  });
  connect(ui_->action_disconnect    , &QAction::triggered       , this, [&] 
  {
    client_.reset();
    statusBar()->showMessage("Disconnected from server.");
  });
  connect(ui_->action_exit          , &QAction::triggered       , this, [&] 
  {
    std::exit(0);
  });
  
  connect(ui_->button_render        , &QPushButton::clicked     , this, [&]
  {
    if (client_)
      client_->make_request();
  });
  connect(ui_->checkbox_autorender  , &QCheckBox  ::stateChanged, this, [&]
  {
    if (client_)
      client_->set_auto_request(ui_->checkbox_autorender->isChecked());
  });

  // TODO: Program toolbox elements.
  
  statusBar()->showMessage("Initialization successful.");
}

void window::make_client(const std::string& address)
{
  statusBar()->showMessage("Connecting to remote server " + QString::fromStdString(address) + ".");

  client_ = std::make_unique<client>(address);
  connect(client_.get(), &client::on_send_request    , this, [&]
  {
    auto& request = client_->request_data();

    // TODO: Fill the request.
  });
  connect(client_.get(), &client::on_receive_response, this, [&]
  {
    const auto& image = client_->response_data();
    ui_->image->setPixmap(QPixmap::fromImage(QImage(
      reinterpret_cast<const unsigned char*>(image.data().c_str()),
      image.size().x(),
      image.size().y(),
      QImage::Format_RGB888)));
  });

  statusBar()->showMessage("Connected to remote server " + QString::fromStdString(address) + ".");
}
}
