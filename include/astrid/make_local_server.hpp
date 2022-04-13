#pragma once

#include <QApplication>
#include <QProcess>

namespace ast
{
inline void make_local_server()
{
  static QProcess process;
  if (process.state() == QProcess::ProcessState::NotRunning)
  {
    process.start         (QApplication::arguments().at(0), {"-s"});
    process.waitForStarted();
  }
}
}