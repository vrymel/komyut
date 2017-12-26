defmodule WaypointsDirectWeb.LayoutView do
  use WaypointsDirectWeb, :view

  def is_development_env do
    System.get_env("APP_ENV") === "development"
  end
end
