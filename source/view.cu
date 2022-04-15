#include <astrid/view.hpp>

#include <astrid/window.hpp>

namespace ast
{
view::view(QWidget* parent) : QLabel(parent), window_(dynamic_cast<ast::window*>(parent->parent()->parent())), timer_(std::make_unique<QTimer>(this))
{
  setFocusPolicy  (Qt::StrongFocus);
  setMouseTracking(true);
  
  transform_.translation = {
    window_->ui()->line_edit_position_x->text().toFloat(),
    window_->ui()->line_edit_position_y->text().toFloat(),
    window_->ui()->line_edit_position_z->text().toFloat()};
  transform_.rotation_from_euler({
    to_radians(window_->ui()->line_edit_rotation_x->text().toFloat()),
    to_radians(window_->ui()->line_edit_rotation_y->text().toFloat()),
    to_radians(window_->ui()->line_edit_rotation_z->text().toFloat())});
  // TODO: Subscribe to line edit callbacks to keep in sync.

  connect(timer_.get(), &QTimer::timeout, this, [&]
  {
    transform<float>::vector_type position {
      window_->ui()->line_edit_position_x->text().toFloat(),
      window_->ui()->line_edit_position_y->text().toFloat(),
      window_->ui()->line_edit_position_z->text().toFloat()
    };

    if (key_map_[Qt::Key_D]) position += transform_.right  () * move_speed_;
    if (key_map_[Qt::Key_A]) position -= transform_.right  () * move_speed_;
    if (key_map_[Qt::Key_E]) position += transform_.up     () * move_speed_;
    if (key_map_[Qt::Key_Q]) position -= transform_.up     () * move_speed_;
    if (key_map_[Qt::Key_W]) position += transform_.forward() * move_speed_;
    if (key_map_[Qt::Key_S]) position -= transform_.forward() * move_speed_;
    
    window_->ui()->line_edit_position_x->setText(QString::number(position[0]));
    window_->ui()->line_edit_position_y->setText(QString::number(position[1]));
    window_->ui()->line_edit_position_z->setText(QString::number(position[2]));
  });
  timer_->start(16);
}

void view::keyPressEvent    (QKeyEvent*   event)
{
  QLabel::keyPressEvent(event);
  
  if (event->key() == Qt::Key_D) key_map_[Qt::Key_D] = true;
  if (event->key() == Qt::Key_A) key_map_[Qt::Key_A] = true;
  if (event->key() == Qt::Key_E) key_map_[Qt::Key_E] = true;
  if (event->key() == Qt::Key_Q) key_map_[Qt::Key_Q] = true;
  if (event->key() == Qt::Key_W) key_map_[Qt::Key_W] = true;
  if (event->key() == Qt::Key_S) key_map_[Qt::Key_S] = true;
}
void view::keyReleaseEvent  (QKeyEvent*   event)
{
  QLabel::keyReleaseEvent(event);
  
  if (event->key() == Qt::Key_D) key_map_[Qt::Key_D] = false;
  if (event->key() == Qt::Key_A) key_map_[Qt::Key_A] = false;
  if (event->key() == Qt::Key_E) key_map_[Qt::Key_E] = false;
  if (event->key() == Qt::Key_Q) key_map_[Qt::Key_Q] = false;
  if (event->key() == Qt::Key_W) key_map_[Qt::Key_W] = false;
  if (event->key() == Qt::Key_S) key_map_[Qt::Key_S] = false;
}
void view::mousePressEvent  (QMouseEvent* event)
{
  QLabel::mousePressEvent(event);

  last_mouse_position_ = event->pos();
}
void view::mouseReleaseEvent(QMouseEvent* event)
{
  QLabel::mouseReleaseEvent(event);
}
void view::mouseMoveEvent   (QMouseEvent* event)
{
  QLabel::mouseMoveEvent(event);

  if (event->buttons() & Qt::LeftButton && !window_->ui()->checkbox_look_at_origin->isChecked())
  {
    const auto dx = event->x() - last_mouse_position_.x();
    const auto dy = event->y() - last_mouse_position_.y();
    transform_.rotation = transform_.rotation * ast::angle_axis<float>(to_radians(look_speed_ * dx), transform<float>::vector_type::UnitY());
    transform_.rotation = transform_.rotation * ast::angle_axis<float>(to_radians(look_speed_ * dy), transform_.right());
    
    auto euler = transform_.rotation_to_euler();
    window_->ui()->line_edit_rotation_x->setText(QString::number(to_degrees(euler[0])));
    window_->ui()->line_edit_rotation_y->setText(QString::number(to_degrees(euler[1])));
    window_->ui()->line_edit_rotation_z->setText(QString::number(to_degrees(euler[2])));
  }

  last_mouse_position_ = event->pos();
}
}