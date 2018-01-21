defmodule WaypointsDirectWeb.Router do
  use WaypointsDirectWeb, :router

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

  scope "/", WaypointsDirectWeb do
    pipe_through :browser

    get "/", LandingController, :index
  end

  scope "/routes", WaypointsDirectWeb do
    pipe_through :browser

    # Temporary comment this so we can restrict index and the new route
    # resources "/", RouteController
    get "/", RouteController, :index

    # Obfuscate "new" so we only have access, for now
    get "/22af645d1859cb5ca6da0c484f1f37ea", RouteController, :new
  end

  scope "/api/routes", WaypointsDirectWeb do
    pipe_through :api

    resources "/", RouteApiController
    get "/get_segment_waypoints/:segment_id", RouteApiController, :get_segment_waypoints
    get "/get_city_routes/:city_id", RouteApiController, :get_city_routes
  end

  scope "/api/intersections", WaypointsDirectWeb do
    pipe_through :api

    resources "/", IntersectionApiController
  end

  scope "/api/graph", WaypointsDirectWeb do
    pipe_through :api

    get "/search", GraphController, :search_possible_route
  end

  # Other scopes may use custom stacks.
  # scope "/api", WaypointsDirect do
  #   pipe_through :api
  # end
end
