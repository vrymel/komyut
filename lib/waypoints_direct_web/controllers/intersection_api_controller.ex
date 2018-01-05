defmodule WaypointsDirectWeb.IntersectionApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Intersection

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