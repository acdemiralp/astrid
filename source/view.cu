#include <astrid/view.hpp>

#include <astrid/window.hpp>

namespace ast
{
view::view(QWidget* parent) : window_(dynamic_cast<ast::window*>(parent->parent()->parent())), timer_(std::make_unique<QTimer>(this))
{
  setFocusPolicy  (Qt::StrongFocus);
  setMouseTracking(true);

  connect(timer_.get(), &QTimer::timeout, this, [&]
  {
    // TODO: Should be according to rotation. Use transform_.
    const auto speed = 1e-2f;
    if (key_map_[Qt::Key_D]) window_->ui()->line_edit_position_x->setText(QString::number(window_->ui()->line_edit_position_x->text().toFloat() + speed));
    if (key_map_[Qt::Key_A]) window_->ui()->line_edit_position_x->setText(QString::number(window_->ui()->line_edit_position_x->text().toFloat() - speed));
    if (key_map_[Qt::Key_E]) window_->ui()->line_edit_position_y->setText(QString::number(window_->ui()->line_edit_position_y->text().toFloat() + speed));
    if (key_map_[Qt::Key_Q]) window_->ui()->line_edit_position_y->setText(QString::number(window_->ui()->line_edit_position_y->text().toFloat() - speed));
    if (key_map_[Qt::Key_W]) window_->ui()->line_edit_position_z->setText(QString::number(window_->ui()->line_edit_position_z->text().toFloat() + speed));
    if (key_map_[Qt::Key_S]) window_->ui()->line_edit_position_z->setText(QString::number(window_->ui()->line_edit_position_z->text().toFloat() - speed));
    if (dragging_)
    {
      // TODO: Update rotation.
    }
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

  if (event->button() == 0)
    dragging_ = true;
}
void view::mouseReleaseEvent(QMouseEvent* event)
{
  QLabel::mouseReleaseEvent(event);

  if (event->button() == 0)
    dragging_ = false;
}
void view::mouseMoveEvent   (QMouseEvent* event)
{
  QLabel::mouseMoveEvent(event);

  // TODO
}
}