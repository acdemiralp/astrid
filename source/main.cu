#include <cstdint>

#include <cxxopts.hpp>

#include <astrid/service.hpp>
#include <astrid/user_interface.hpp>

std::int32_t main(const std::int32_t argc, char** argv)
{
  cxxopts::Options options("Astrid", "A relativistic ray tracing server and end-user application built on Astray.");
  options.add_options()
    ("s,server", "Launch as headless server.", cxxopts::value<bool>        ()->default_value("false"))
    ("p,port"  , "Server port."              , cxxopts::value<std::int32_t>()->default_value("3000" ));
  const auto result = options.parse(argc, argv);

  return result.count("server") ? ast::service::run(result) : ast::user_interface::run(result);
}