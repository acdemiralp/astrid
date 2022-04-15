#include <astrid/window.hpp>

#include <astray/api.hpp>
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
  
  connect(ui_->action_connect_local          , &QAction    ::triggered         , this, [&] 
  {
    create_client();
  });
  connect(ui_->action_connect_remote         , &QAction    ::triggered         , this, [&] 
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
  connect(ui_->action_disconnect             , &QAction    ::triggered         , this, [&] 
  {
    destroy_client();
  });
  connect(ui_->action_exit                   , &QAction    ::triggered         , this, [&] 
  {
    std::exit(0);
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
  
  connect(ui_->combobox_projection_type      , &QComboBox  ::currentTextChanged, this, [&] (const QString& text)
  {
    const bool is_perspective = text == "perspective";
    ui_->line_edit_fov_y       ->setEnabled( is_perspective);
    ui_->line_edit_focal_length->setEnabled( is_perspective);
    ui_->line_edit_size_ortho  ->setEnabled(!is_perspective);
  });
   
  statusBar()->showMessage("Initialization successful.");
}

void window::create_client (const std::string& address)
{
  statusBar()->showMessage("Connecting to " + QString::fromStdString(address) + ". Please wait.");
  repaint  ();

  try
  {
    client_ = std::make_unique<client>(address);

    connect(client_.get(), &client::on_send_request    , this, [&]
    {
      if (!client_) return;

      statusBar()->showMessage("Sending render request to the server. Please wait.");

      auto& request = client_->request_data();

      // TODO: Ideally only set the values that have changed.
      static QString cached_metric;
      if (ui_->combobox_metric->currentText() != cached_metric)
      {
        *request.mutable_metric() = ui_->combobox_metric->currentText().toStdString();
        cached_metric = ui_->combobox_metric->currentText();
      }
      else
        request.clear_metric();

      request.mutable_image_size  ()->set_x((ui_->image->width () / 2) * 2 - 2 * ui_->image->frameWidth());
      request.mutable_image_size  ()->set_y((ui_->image->height() / 2) * 2 - 2 * ui_->image->frameWidth());

      request.set_iterations      (ui_->line_edit_iterations      ->text().toULongLong());
      request.set_lambda_step_size(ui_->line_edit_lambda_step_size->text().toFloat    ());
      request.set_lambda          (ui_->line_edit_lambda          ->text().toFloat    ());
      request.set_debug           (ui_->checkbox_debug            ->isChecked());

      if (ui_->checkbox_use_bounds->isChecked())
      {
        request.mutable_bounds()->mutable_lower()->set_t(ui_->line_edit_lower_bound_t->text().toFloat());
        request.mutable_bounds()->mutable_lower()->set_x(ui_->line_edit_lower_bound_x->text().toFloat());
        request.mutable_bounds()->mutable_lower()->set_y(ui_->line_edit_lower_bound_y->text().toFloat());
        request.mutable_bounds()->mutable_lower()->set_z(ui_->line_edit_lower_bound_z->text().toFloat());
        request.mutable_bounds()->mutable_upper()->set_t(ui_->line_edit_upper_bound_t->text().toFloat());
        request.mutable_bounds()->mutable_upper()->set_x(ui_->line_edit_upper_bound_x->text().toFloat());
        request.mutable_bounds()->mutable_upper()->set_y(ui_->line_edit_upper_bound_y->text().toFloat());
        request.mutable_bounds()->mutable_upper()->set_z(ui_->line_edit_upper_bound_z->text().toFloat());
      }
      else
        request.clear_bounds();

      request.mutable_transform()->set_time              (ui_->line_edit_coordinate_time->text().toFloat());
      request.mutable_transform()->mutable_position      ()->set_x(ui_->line_edit_position_x->text().toFloat());
      request.mutable_transform()->mutable_position      ()->set_y(ui_->line_edit_position_y->text().toFloat());
      request.mutable_transform()->mutable_position      ()->set_z(ui_->line_edit_position_z->text().toFloat());
      request.mutable_transform()->mutable_rotation_euler()->set_x(ui_->line_edit_rotation_x->text().toFloat());
      request.mutable_transform()->mutable_rotation_euler()->set_y(ui_->line_edit_rotation_y->text().toFloat());
      request.mutable_transform()->mutable_rotation_euler()->set_z(ui_->line_edit_rotation_z->text().toFloat());
      request.mutable_transform()->set_look_at_origin    (ui_->checkbox_look_at_origin->isChecked());

      if (ui_->combobox_projection_type->currentText() == "perspective")
      {
        request.clear_orthographic  ();
        request.mutable_perspective ()->set_y_field_of_view(ui_->line_edit_fov_y       ->text().toFloat());
        request.mutable_perspective ()->set_focal_length   (ui_->line_edit_focal_length->text().toFloat());
        request.mutable_perspective ()->set_near_clip      (ui_->line_edit_near_clip   ->text().toFloat());
        request.mutable_perspective ()->set_far_clip       (ui_->line_edit_far_clip    ->text().toFloat());
      }
      else
      {
        request.clear_perspective   ();
        request.mutable_orthographic()->set_height         (ui_->line_edit_size_ortho  ->text().toFloat());
        request.mutable_orthographic()->set_near_clip      (ui_->line_edit_near_clip   ->text().toFloat());
        request.mutable_orthographic()->set_far_clip       (ui_->line_edit_far_clip    ->text().toFloat());
      }

      static QString cached_background;
      if (!ui_->line_edit_background->text().isNull () &&
          !ui_->line_edit_background->text().isEmpty() &&
           ui_->combobox_metric->currentText() != cached_metric || // TODO: Horrid. A metric change invalidates all parameters.
           ui_->line_edit_background->text() != cached_background)
      {
        image<vector3<std::uint8_t>> image;
        image.load(ui_->line_edit_background->text().toStdString());
        
        request.mutable_background_image()->set_data(static_cast<void*>(image.data.data()), image.data.size() * sizeof(vector3<std::uint8_t>));
        request.mutable_background_image()->mutable_size()->set_x(image.size[0]);
        request.mutable_background_image()->mutable_size()->set_y(image.size[1]);

        cached_background = ui_->line_edit_background->text();
      }
      else
        request.clear_background_image();
      
      client_->request_cv().notify_all();
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
          QImage::Format_RGB888))); // TODO: QImage bugs out for certain x, y.
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
  catch (const std::runtime_error& error)
  {
    statusBar()->showMessage("Failed to connect " + QString::fromStdString(address) + ".");
  }
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