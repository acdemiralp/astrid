#include <astrid/service.hpp>

#include <iostream>
#include <memory>
#include <string>
#include <vector>

#include <astray/api.hpp>
#include <zmq.hpp>

#include <image.pb.h>
#include <request.pb.h>

namespace ast
{
template <
  typename scalar_type , 
  typename metric_type = metrics::kerr<scalar_type>,
  typename motion_type = geodesic<scalar_type, runge_kutta_4_tableau<scalar_type>>>
constexpr auto make_ray_tracer(const request& request)
{
  auto ray_tracer = std::make_unique<ast::ray_tracer<metric_type, motion_type>>(
    vector2<std::int32_t>   (request.image_size().x(), request.image_size().y()),
    metric_type             (),
    request.iterations      (),
    request.lambda_step_size(),
    request.lambda          (),
    aabb4<scalar_type>(
      vector4<scalar_type>(request.lower_bound().t(), request.lower_bound().x(), request.lower_bound().y(), request.lower_bound().z()),
      vector4<scalar_type>(request.upper_bound().t(), request.upper_bound().x(), request.upper_bound().y(), request.upper_bound().z())),
    typename motion_type::error_evaluator_type(),
    request.debug           ());
  
  ray_tracer->observer.coordinate_time             = request.coordinate_time();
  ray_tracer->observer.transform.translation       = {request.position().x(), request.position().y(), request.position().z()};
  ray_tracer->observer.transform.rotation_from_euler({request.rotation().x(), request.rotation().y(), request.rotation().z()});
  if (request.look_at_origin())
    ray_tracer->observer.transform.look_at({0, 0, 0});
  
  if      (request.projection_type() == "perspective")
    ray_tracer->observer.projection = perspective_projection<scalar_type>
    {
      request.projection_fov_y       (),
      static_cast<scalar_type>(request.image_size().x()) / request.image_size().y(),
      request.projection_focal_length(),
      request.projection_near_clip   (),
      request.projection_far_clip    ()
    };
  else if (request.projection_type() == "orthographic")
    ray_tracer->observer.projection = orthographic_projection<scalar_type>
    {
      request.projection_height     (),
      static_cast<scalar_type>(request.image_size().x()) / request.image_size().y(),
      request.projection_near_clip  (),
      request.projection_far_clip   ()
    };
  
  ray_tracer->background.load(request.background_image());

  return std::move(ray_tracer);
}

std::int32_t service::run(const cxxopts::ParseResult& options)
{
  mpi::environment  environment ;
  mpi::communicator communicator;

  zmq::context_t    context(1);
  zmq::socket_t     socket (context, ZMQ_PAIR);
  if (communicator.rank() == 0)
  {
    std::string address = std::string("tcp://*:") + (options.count("port") ? std::to_string(options["port"].as<std::int32_t>()) : "3000");
    socket.bind(address);
    std::cout << "Service running at: " << address << "\n";
  }
  
  ::request request;
  while (!request.terminate())
  {
    std::int32_t              size;
    std::vector<std::uint8_t> data;

    if (communicator.rank() == 0)
    {
      zmq::message_t message;
      socket.recv(message, zmq::recv_flags::none);

      size = static_cast<std::int32_t>(message.size());
      data.resize(message.size());
      std::copy_n(static_cast<std::uint8_t*>(message.data()), message.size(), data.begin());
    }
    
    communicator.bcast         (&size      , 1   , mpi::data_type(MPI_INT ));
    data        .resize        (size);
    communicator.bcast         (data.data(), size, mpi::data_type(MPI_BYTE));
    request     .ParseFromArray(data.data(), static_cast<std::int32_t>(data.size()));
    
    image<vector3<std::uint8_t>> result;
    if      (request.metric_type() == "minkowski")
      result = make_ray_tracer<float, metrics::minkowski      <float>>(request)->render_frame();
    else if (request.metric_type() == "goedel")
      result = make_ray_tracer<float, metrics::goedel         <float>>(request)->render_frame();
    else if (request.metric_type() == "schwarzschild")
      result = make_ray_tracer<float, metrics::schwarzschild  <float>>(request)->render_frame();
    else if (request.metric_type() == "kerr")
      result = make_ray_tracer<float, metrics::kerr           <float>>(request)->render_frame();
    else if (request.metric_type() == "kastor_traschen")
      result = make_ray_tracer<float, metrics::kastor_traschen<float>>(request)->render_frame();

    if (communicator.rank() == 0)
    {
      ::image image;
      image.set_data(static_cast<void*>(result.data.data()), result.data.size() * sizeof(vector3<std::uint8_t>));
      image.mutable_size()->set_x (result.size[0]);
      image.mutable_size()->set_y (result.size[1]);
      auto string = image.SerializeAsString();

      zmq::message_t message(string.begin(), string.end());
      socket.send(message, zmq::send_flags::none);
      std::cout << "Sent image with size: " << image.size().x() << " " << image.size().y() << "\n";
    }
  }

  return 0;
}
}