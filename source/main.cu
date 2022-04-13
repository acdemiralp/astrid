#include <cstdint>

#include <cxxopts.hpp>

#include <astrid/service.hpp>
#include <astrid/user_interface.hpp>

std::int32_t main(const std::int32_t argc, char** argv)
{
  cxxopts::Options configuration("Astrid", "A relativistic ray tracing server and end-user application.");
  configuration.add_options()
    ("s,server", "Launch as headless server.", cxxopts::value<bool>        ()->default_value("false"))
    ("p,port"  , "Server port."              , cxxopts::value<std::int32_t>()->default_value("3000" ));
  const auto options = configuration.parse(argc, argv);

  if (options.count("server"))
  {
    ast::service service(options);
    service.run();
  }
  else
  {
    ast::user_interface::run(argc, argv, options);
  }

  return 0;
}