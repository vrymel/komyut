defmodule WaypointsDirect.Router do
  use WaypointsDirect.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WaypointsDirect do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/users", WaypointsDirect do 
    pipe_through :browser

    resources "/", UserController
  end

  scope "/routes", WaypointsDirect do
    pipe_through :browser

    resources "/", RouteController
  end

  scope "/api/routes", WaypointsDirect do
    pipe_through :browser

    resources "/", RouteApiController
    get "/get_segment_waypoints/:segment_id", RouteApiController, :get_segment_waypoints
    get "/get_city_routes/:city_id", RouteApiController, :get_city_routes
  end

  # Other scopes may use custom stacks.
  # scope "/api", WaypointsDirect do
  #   pipe_through :api
  # end
end
