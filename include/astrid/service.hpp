#pragma once

#include <cstdint>

#include <astray/api.hpp>

namespace ast
{
class service
{
public:
  service           (std::int32_t argc, char** argv);
  service           (const service&  that) = delete ;
  service           (      service&& temp) = default;
  virtual ~service  ()                     = default;
  service& operator=(const service&  that) = delete ;
  service& operator=(      service&& temp) = default;

  std::int32_t run();

protected:

};
}