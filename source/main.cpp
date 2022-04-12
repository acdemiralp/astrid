#include <cstdint>

#include <astrid/service.hpp>

std::int32_t main(const std::int32_t argc, char** argv)
{
  return ast::service::run(argc, argv);
}