#include <astrid/user_interface.hpp>

#include <QApplication>

#include <astrid/window.hpp>

namespace ast
{
std::int32_t user_interface::run(std::int32_t argc, char** argv)
{
  QApplication application(argc, argv);

  window window;
  window.show();

  return application.exec();
}
}