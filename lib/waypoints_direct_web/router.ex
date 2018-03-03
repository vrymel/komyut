defmodule WaypointsDirectWeb.Router do
  use WaypointsDirectWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  require Ueberauth

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

  pipeline :secure do
    plug WaypointsDirect.Plug.Secure
  end

  scope "/", WaypointsDirectWeb do
    pipe_through :browser

    get "/", LandingController, :index
    get "/logout", AuthController, :logout
  end

  scope "/auth", WaypointsDirectWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
  end

  scope "/routes", WaypointsDirectWeb do
    pipe_through :browser

    get "/", RouteController, :index
  end

  scope "/management/routes", WaypointsDirectWeb do
    pipe_through [:browser, :secure]

    get "/new", RouteManagementController, :new
  end

  scope "/api/routes", WaypointsDirectWeb do
    pipe_through :api

    resources "/", RouteApiController
  end
  
  scope "/api/intersections", WaypointsDirectWeb do
    pipe_through :api

    resources "/", IntersectionApiController
  end

  scope "/api/graph", WaypointsDirectWeb do
    pipe_through :api

    get "/search_path", GraphApiController, :search_path
  end

  # Other scopes may use custom stacks.
  # scope "/api", WaypointsDirect do
  #   pipe_through :api
  # end
end
