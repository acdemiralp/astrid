#pragma once

#include <cstdint>

#include <cxxopts.hpp>

namespace ast::service
{
std::int32_t run(const cxxopts::ParseResult& options);
}