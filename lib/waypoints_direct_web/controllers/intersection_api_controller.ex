defmodule WaypointsDirectWeb.IntersectionApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Intersection

    def index(conn, _params) do
      intersections = Repo.all(Intersection) 
      |> Enum.map(fn(intersection) -> intersection |> Map.from_struct |> Map.take [:lat, :lng] end)

      json conn, %{success: true, intersections: intersections}
    end

    def create(conn, %{"lat" => lat, "lng" => lng}) do
      changeset = Intersection.changeset(%Intersection{}, %{lat: lat, lng: lng})

      case Repo.insert(changeset) do
        {:ok, intersection} -> 
          json conn, %{success: true, intersection_id: intersection.id}
        {:error, _} ->
          json conn, %{success: false}
      end
    end
end