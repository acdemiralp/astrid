#pragma once

#include <cstdint>

#include <cxxopts.hpp>

namespace ast::user_interface
{
std::int32_t run(const cxxopts::ParseResult& options);
}