#include <astrid/user_interface.hpp>

#include <QApplication>
#include <QMainWindow>
#include <QSurfaceFormat>

namespace ast
{
std::int32_t user_interface::run(std::int32_t argc, char** argv, const cxxopts::ParseResult& options)
{
  QSurfaceFormat format;
  format.setProfile     (QSurfaceFormat::CompatibilityProfile);
  format.setSwapBehavior(QSurfaceFormat::DoubleBuffer        );
  format.setSamples     (4);
  format.setVersion     (4, 5);
  QSurfaceFormat::setDefaultFormat(format);

  QApplication application(argc, argv);

  QMainWindow window;
  window.setWindowTitle("Astrid");
  window.resize        (640, 480);
  window.show          ();
  // TODO

  return application.exec();
}
}
