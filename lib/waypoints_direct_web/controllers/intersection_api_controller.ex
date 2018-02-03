defmodule WaypointsDirectWeb.IntersectionApiController do
    use WaypointsDirectWeb, :controller

    alias WaypointsDirect.Intersection

    def index(conn, _params) do
      intersections = Repo.all(Intersection) 
      |> Enum.map(fn(intersection) -> intersection |> Map.from_struct |> Map.take [:id, :lat, :lng] end)

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

    def delete(conn, %{"id" => id}) do
      intersection = Repo.get Intersection, id

      if intersection do
        case Repo.delete intersection  do
          {:ok, _} -> true
          {:error, _} -> false
        end
      end

      json conn, %{success: true}
    end

end