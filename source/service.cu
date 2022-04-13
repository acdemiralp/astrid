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
  request                   request     ;
  ::image                   response    ;
  std::int32_t              message_size;
  std::vector<std::uint8_t> message_data;
  image_type                image       ;

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
  if (request.has_metric())
  {
    if      (request.metric() == "minkowski")
      ray_tracer_.emplace<ray_tracer<metrics::minkowski      <scalar_type>, motion_type>>();
    else if (request.metric() == "goedel")
      ray_tracer_.emplace<ray_tracer<metrics::goedel         <scalar_type>, motion_type>>();
    else if (request.metric() == "schwarzschild")
      ray_tracer_.emplace<ray_tracer<metrics::schwarzschild  <scalar_type>, motion_type>>();
    else if (request.metric() == "kerr")
      ray_tracer_.emplace<ray_tracer<metrics::kerr           <scalar_type>, motion_type>>();
    else if (request.metric() == "kastor_traschen")
      ray_tracer_.emplace<ray_tracer<metrics::kastor_traschen<scalar_type>, motion_type>>();
  }

  std::visit([&] (auto& ray_tracer)
  {
    if (request.has_image_size      ())
      ray_tracer.partitioner.set_domain_size({request.image_size().x(), request.image_size().y()});
    if (request.has_iterations      ())
      ray_tracer.iterations       = request.iterations();
    if (request.has_lambda_step_size())
      ray_tracer.lambda_step_size = request.lambda_step_size();
    if (request.has_lambda          ())
      ray_tracer.lambda           = request.lambda();
    if (request.has_debug           ())
      ray_tracer.debug            = request.debug();
    
    if (request.has_bounds          ())
    {
      auto& bounds = request.bounds();
      auto& lower  = bounds .lower ();
      auto& upper  = bounds .upper ();
      ray_tracer.bounds           = aabb4<scalar_type>(
        vector4<scalar_type>(lower.t(), lower.x(), lower.y(), lower.z()),
        vector4<scalar_type>(upper.t(), upper.x(), upper.y(), upper.z()));
    }

    if (request.has_transform       ())
    {
      auto& transform = request.transform();

      if (transform.has_time          ())
        ray_tracer.observer.coordinate_time = request.transform().time();

      if (transform.has_position      ())
      {
        auto& position = transform.position();
        ray_tracer.observer.transform.translation = {position.x(), position.y(), position.z()};
      }
      
      if (transform.has_rotation_euler())
      {
        auto& rotation = transform.rotation_euler();
        ray_tracer.observer.transform.rotation_from_euler({rotation.x(), rotation.y(), rotation.z()});
      }

      if (transform.has_look_at_origin() && transform.look_at_origin())
        ray_tracer.observer.transform.look_at({0, 0, 0});
    }

    if (request.has_perspective     ())
    {
      if (!std::holds_alternative<perspective_projection<scalar_type>>(ray_tracer.observer.projection))
      {
        const auto& image_size         = ray_tracer.partitioner.domain_size();
        const auto  aspect_ratio       = static_cast<scalar_type>(image_size[0]) / static_cast<scalar_type>(image_size[1]);
        ray_tracer.observer.projection = perspective_projection<scalar_type> {to_radians<scalar_type>(75), aspect_ratio};
      }

      const auto& perspective          = request.perspective();
      auto&       cast_projection      = std::get<perspective_projection<scalar_type>>(ray_tracer.observer.projection);

      if (perspective.has_y_field_of_view())
        cast_projection.fov_y          = perspective.y_field_of_view();
      if (perspective.has_focal_length   ())
        cast_projection.focal_length   = perspective.focal_length   ();
      if (perspective.has_near_clip      ())
        cast_projection.near_clip      = perspective.near_clip      ();
      if (perspective.has_far_clip       ())
        cast_projection.far_clip       = perspective.far_clip       ();
    }

    if (request.has_orthographic    ())
    {
      if (!std::holds_alternative<orthographic_projection<scalar_type>>(ray_tracer.observer.projection))
      {
        const auto& image_size         = ray_tracer.partitioner.domain_size();
        const auto  aspect_ratio       = static_cast<scalar_type>(image_size[0]) / static_cast<scalar_type>(image_size[1]);
        ray_tracer.observer.projection = orthographic_projection<scalar_type> {1, aspect_ratio};
      }

      const auto& perspective          = request.orthographic();
      auto&       cast_projection      = std::get<orthographic_projection<scalar_type>>(ray_tracer.observer.projection);
      
      if (perspective.has_height   ())
        cast_projection.height         = perspective.height   ();
      if (perspective.has_near_clip())
        cast_projection.near_clip      = perspective.near_clip();
      if (perspective.has_far_clip ())
        cast_projection.far_clip       = perspective.far_clip ();
    }

    if (request.has_background_image())
    {
      auto& background = request.background_image();
      ray_tracer.background.size = {background.size().x(), background.size().y()};
      ray_tracer.background.data.resize(ray_tracer.background.size.prod());
      std::copy_n(background.data().data(), background.data().size(), reinterpret_cast<std::uint8_t*>(ray_tracer.background.data.data()));
    }
  }, ray_tracer_);
}
}