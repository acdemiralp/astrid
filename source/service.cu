#include <astrid/service.hpp>

#include <iostream>
#include <string>
#include <vector>

#include <astray/api.hpp>
#include <zmq.hpp>

namespace ast
{
service::service(const cxxopts::ParseResult& options)
{
  if (communicator_.rank() == 0)
  {
    const auto address = std::string("tcp://*:") + (options.count("port") ? std::to_string(options["port"].as<std::int32_t>()) : "3000");
    socket_.bind(address);
    std::cout << "Socket bound at: " << address << ".\n";
  }
}

void service::run      ()
{
  request                      request     ;
  ::image                      response    ;
  std::int32_t                 message_size;
  std::vector<std::uint8_t>    message_data;
  image_type                   image       ;

  while (!request.terminate())
  {
    if (communicator_.rank() == 0)
    {
      zmq::message_t message;
      socket_.recv(message, zmq::recv_flags::none);

      message_size = static_cast<std::int32_t>(message.size());
      message_data.resize(message.size());
      std::copy_n(static_cast<std::uint8_t*>(message.data()), message.size(), message_data.begin());
    }
    
    communicator_.bcast         (&message_size      , 1           , mpi::data_type(MPI_INT ));
    message_data .resize        (message_size);
    communicator_.bcast         (message_data.data(), message_size, mpi::data_type(MPI_BYTE));
    request      .ParseFromArray(message_data.data(), static_cast<std::int32_t>(message_data.size()));
    
    configure(request);
    std::visit([&] (auto& ray_tracer) { image = ray_tracer.render_frame(); }, ray_tracer_);

    if (communicator_.rank() == 0)
    {
      response.set_data(static_cast<void*>(image.data.data()), image.data.size() * sizeof(vector3<std::uint8_t>));
      response.mutable_size()->set_x (image.size[0]);
      response.mutable_size()->set_y (image.size[1]);
      auto string = response.SerializeAsString();

      zmq::message_t message(string.begin(), string.end());
      socket_.send(message, zmq::send_flags::none);

      std::cout << "Sent response with size: " << response.size().x() << " " << response.size().y() << ".\n";
    }
  }
}

void service::configure(const request& request)
{
  //if      (request.metric_type() == "minkowski")
  //  ray_tracer_ = make_ray_tracer<scalar_type, metrics::goedel         <scalar_type>>(request);
  //else if (request.metric_type() == "goedel")
  //  ray_tracer_ = make_ray_tracer<float, metrics::goedel         <float>>(request);
  //else if (request.metric_type() == "schwarzschild")
  //  make_ray_tracer<float, metrics::schwarzschild  <float>>(request);
  //else if (request.metric_type() == "kerr")
  //  make_ray_tracer<float, metrics::kerr           <float>>(request);
  //else if (request.metric_type() == "kastor_traschen")
  //  make_ray_tracer<float, metrics::kastor_traschen<float>>(request);
  
  //auto ray_tracer = ast::ray_tracer<metric_type, motion_type>(
  //  vector2<std::int32_t>   (request.image_size().x(), request.image_size().y()),
  //  metric_type             (),
  //  request.iterations      (),
  //  request.lambda_step_size(),
  //  request.lambda          (),
  //  aabb4<scalar_type>(
  //    vector4<scalar_type>(request.lower_bound().t(), request.lower_bound().x(), request.lower_bound().y(), request.lower_bound().z()),
  //    vector4<scalar_type>(request.upper_bound().t(), request.upper_bound().x(), request.upper_bound().y(), request.upper_bound().z())),
  //  typename motion_type::error_evaluator_type(),
  //  request.debug           ());
  //
  //ray_tracer->observer.coordinate_time             = request.coordinate_time();
  //ray_tracer->observer.transform.translation       = {request.position().x(), request.position().y(), request.position().z()};
  //ray_tracer->observer.transform.rotation_from_euler({request.rotation().x(), request.rotation().y(), request.rotation().z()});
  //if (request.look_at_origin())
  //  ray_tracer->observer.transform.look_at({0, 0, 0});
  //
  //if      (request.projection_type() == "perspective")
  //  ray_tracer->observer.projection = perspective_projection<scalar_type>
  //  {
  //    request.projection_fov_y       (),
  //    static_cast<scalar_type>(request.image_size().x()) / request.image_size().y(),
  //    request.projection_focal_length(),
  //    request.projection_near_clip   (),
  //    request.projection_far_clip    ()
  //  };
  //else if (request.projection_type() == "orthographic")
  //  ray_tracer->observer.projection = orthographic_projection<scalar_type>
  //  {
  //    request.projection_height     (),
  //    static_cast<scalar_type>(request.image_size().x()) / request.image_size().y(),
  //    request.projection_near_clip  (),
  //    request.projection_far_clip   ()
  //  };
  //
  //ray_tracer->background.load(request.background_image());
}
}