#pragma once

#include <memory>
#include <unordered_map>

#include <astray/math/transform.hpp>
#include <QLabel>
#include <QKeyEvent>
#include <QMouseEvent>
#include <QTimer>

namespace ast
{
class window;

class view : public QLabel
{
  Q_OBJECT
  
public:
  explicit view(QWidget* parent = nullptr);
  
  void keyPressEvent    (QKeyEvent*   event) override;
  void keyReleaseEvent  (QKeyEvent*   event) override;
  void mousePressEvent  (QMouseEvent* event) override;
  void mouseReleaseEvent(QMouseEvent* event) override;
  void mouseMoveEvent   (QMouseEvent* event) override;
  
protected:
  ast::window*                      window_   ;

  std::unique_ptr<QTimer>           timer_    ;
  std::unordered_map<Qt::Key, bool> key_map_  ;
  bool                              dragging_ ;
  transform<float>                  transform_;
};
}