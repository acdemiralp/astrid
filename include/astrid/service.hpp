#pragma once

#include <cstdint>
#include <variant>

#include <astray/api.hpp>
#include <cxxopts.hpp>
#include <zmq.hpp>

#include <request.pb.h>
#include <response.pb.h>

namespace ast
{
class service
{
public:
  using scalar_type           = float;
  using tableau_type          = runge_kutta_4_tableau<scalar_type>;
  using error_controller_type = proportional_integral_controller<scalar_type, tableau_type>;
  using motion_type           = geodesic<scalar_type, tableau_type, error_controller_type>;
  using ray_tracer_type       = std::variant<
    ray_tracer<metrics::minkowski      <scalar_type>, motion_type>,
    ray_tracer<metrics::goedel         <scalar_type>, motion_type>,
    ray_tracer<metrics::schwarzschild  <scalar_type>, motion_type>,
    ray_tracer<metrics::kerr           <scalar_type>, motion_type>,
    ray_tracer<metrics::kastor_traschen<scalar_type>, motion_type>>;
  
  using pixel_type            = vector3<std::uint8_t>;
  using image_type            = image<pixel_type>;

  explicit service  (const cxxopts::ParseResult& options);
  service           (const service&  that) = delete ;
  service           (      service&& temp) = delete ;
  virtual ~service  ()                     = default;
  service& operator=(const service&  that) = delete ;
  service& operator=(      service&& temp) = delete ;

  void       run      ();

protected:
  void       configure(const request& request);

  mpi::environment  environment_ ;
  mpi::communicator communicator_;
  zmq::context_t    context_     {1};
  zmq::socket_t     socket_      {context_, ZMQ_PAIR};
  ray_tracer_type   ray_tracer_  ;
};
}