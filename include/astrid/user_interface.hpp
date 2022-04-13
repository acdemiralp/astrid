#pragma once

#include <cstdint>

#include <cxxopts.hpp>

namespace ast::user_interface
{
std::int32_t run(std::int32_t argc, char** argv, const cxxopts::ParseResult& options);
}