#include <astrid/window.hpp>

#include <QString>
#include <QFileDialog>
#include <QInputDialog>
#include <QLineEdit>

namespace ast
{
window::window(QWidget* parent) : QMainWindow(parent), ui_(new Ui::main_window)
{
  ui_->setupUi(this);
  
  setWindowTitle("Astrid");
  resize        (1024, 600);
  
  connect(ui_->action_connect_local          , &QAction::triggered             , this, [&] 
  {
    create_client();
  });
  connect(ui_->action_connect_remote         , &QAction::triggered             , this, [&] 
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
      create_client(address.toStdString());
  });
  connect(ui_->action_disconnect             , &QAction::triggered             , this, [&] 
  {
    destroy_client();
  });
  connect(ui_->action_exit                   , &QAction::triggered             , this, [&] 
  {
    std::exit(0);
  });
  
  connect(ui_->button_render                 , &QPushButton::clicked           , this, [&]
  {
    if (client_)
    {
      client_->make_request();
      ui_->button_render->setEnabled(false);
    }
  });
  connect(ui_->checkbox_autorender           , &QCheckBox  ::stateChanged      , this, [&] (const std::int32_t checked)
  {
    if (client_)
      client_->set_auto_request(ui_->checkbox_autorender->isChecked());

    ui_->button_render->setEnabled(!checked);
  });

  connect(ui_->button_iterations_05          , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_iterations;
    const auto value     = line_edit->text().toULongLong() / 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_iterations_2           , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_iterations;
    const auto value     = line_edit->text().toULongLong() * 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_lambda_step_size_05    , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_lambda_step_size;
    const auto value     = line_edit->text().toFloat() / 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_lambda_step_size_2     , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_lambda_step_size;
    const auto value     = line_edit->text().toFloat() * 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_lambda_minus_1         , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_lambda;
    const auto value     = line_edit->text().toFloat() - 1;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_lambda_plus_1          , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_lambda;
    const auto value     = line_edit->text().toFloat() + 1;
    line_edit->setText(QString::number(value));
  });
  
  connect(ui_->button_coordinate_time_minus_1, &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_coordinate_time;
    const auto value     = line_edit->text().toFloat() - 1;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_coordinate_time_plus_1 , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_coordinate_time;
    const auto value     = line_edit->text().toFloat() + 1;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_fov_y_05               , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_fov_y;
    const auto value     = line_edit->text().toFloat() / 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_fov_y_2                , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_fov_y;
    const auto value     = line_edit->text().toFloat() * 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_focal_length_05        , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_focal_length;
    const auto value     = line_edit->text().toFloat() / 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_focal_length_2         , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_focal_length;
    const auto value     = line_edit->text().toFloat() * 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_size_ortho_05          , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_size_ortho;
    const auto value     = line_edit->text().toFloat() / 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_size_ortho_2           , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_size_ortho;
    const auto value     = line_edit->text().toFloat() * 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_near_clip_05           , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_near_clip;
    const auto value     = line_edit->text().toFloat() / 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_near_clip_2            , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_near_clip;
    const auto value     = line_edit->text().toFloat() * 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_far_clip_05            , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_far_clip;
    const auto value     = line_edit->text().toFloat() / 2;
    line_edit->setText(QString::number(value));
  });
  connect(ui_->button_far_clip_2             , &QPushButton::clicked           , this, [&]
  {
    const auto line_edit = ui_->line_edit_far_clip;
    const auto value     = line_edit->text().toFloat() * 2;
    line_edit->setText(QString::number(value));
  });
  
  connect(ui_->checkbox_use_bounds           , &QCheckBox  ::stateChanged      , this, [&] (const std::int32_t checked)
  {
    ui_->line_edit_lower_bound_t->setEnabled(checked);
    ui_->line_edit_lower_bound_x->setEnabled(checked);
    ui_->line_edit_lower_bound_y->setEnabled(checked);
    ui_->line_edit_lower_bound_z->setEnabled(checked);
    ui_->line_edit_upper_bound_t->setEnabled(checked);
    ui_->line_edit_upper_bound_x->setEnabled(checked);
    ui_->line_edit_upper_bound_y->setEnabled(checked);
    ui_->line_edit_upper_bound_z->setEnabled(checked);
  });
  connect(ui_->checkbox_look_at_origin       , &QCheckBox  ::stateChanged      , this, [&] (const std::int32_t checked)
  {
    ui_->line_edit_rotation_x   ->setEnabled(!checked);
    ui_->line_edit_rotation_y   ->setEnabled(!checked);
    ui_->line_edit_rotation_z   ->setEnabled(!checked);
  });

  connect(ui_->button_background_browse      , &QPushButton::clicked           , this, [&]
  {
    const QString filepath = QFileDialog::getOpenFileName(
      this, 
      "Select background image file.",
      QString(),
      "Images (*.bmp *.jpg *.png *.tga)");

    if (!filepath.isNull())
      ui_->line_edit_background->setText(filepath);
  });
  
  connect(ui_->combobox_projection_type      , &QComboBox  ::currentTextChanged, this, [&] (const QString& text)
  {
    const bool is_perspective = text == "Perspective";
    ui_->line_edit_fov_y       ->setEnabled( is_perspective);
    ui_->line_edit_focal_length->setEnabled( is_perspective);
    ui_->line_edit_size_ortho  ->setEnabled(!is_perspective);
  });
   
  statusBar()->showMessage("Initialization successful.");
}

void window::create_client (const std::string& address)
{
  statusBar()->showMessage("Connecting to " + QString::fromStdString(address) + ". Please wait.");

  client_ = std::make_unique<client>(address);
  
  // TODO: Check if connection successful. Right now it assumes everything is normal but gets forever stuck at first render.

  connect(client_.get(), &client::on_send_request    , this, [&]
  {
    if (!client_) return;

    statusBar()->showMessage("Sending render request to the server. Please wait.");

    auto& request = client_->request_data();

    // TODO: Fill the request (ideally only with the values that changed, ideally not here, but whenever the values change).
    request.mutable_image_size()->set_x(ui_->image->width ());
    request.mutable_image_size()->set_y(ui_->image->height());
  });
  connect(client_.get(), &client::on_receive_response, this, [&]
  {
    if (client_)
    {
      statusBar()->showMessage("Received image from the server.");

      const auto& image = client_->response_data();
      ui_->image->setPixmap(QPixmap::fromImage(QImage(
        reinterpret_cast<const unsigned char*>(image.data().c_str()),
        image.size().x(),
        image.size().y(),
        QImage::Format_RGB888)));
    }

    if(!ui_->checkbox_autorender->isChecked())
      ui_->button_render->setEnabled(true);
  });
  connect(client_.get(), &client::on_finalize        , this, [&]
  {
    statusBar()->showMessage("Disconnected from the server.");
    set_ui_state(false);
    client_.reset();
  });

  statusBar()->showMessage("Connected to " + QString::fromStdString(address) + ".");
  set_ui_state(true);
}
void window::destroy_client() 
{
  statusBar()->showMessage("Disconnecting from the server. Please wait.");
  client_->kill();
}

void window::set_ui_state  (const bool connected) const
{
  ui_->action_connect_local ->setEnabled(!connected);
  ui_->action_connect_remote->setEnabled(!connected);
  ui_->action_disconnect    ->setEnabled( connected);
  ui_->frame_render         ->setEnabled( connected);
  ui_->toolbox              ->setEnabled( connected);
}
}