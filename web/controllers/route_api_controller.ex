defmodule HelloPhoenix.RouteApiController do
    use HelloPhoenix.Web, :controller
    
    alias HelloPhoenix.Route
    
    def show(conn, %{"id" => route_id}) do
        route = Repo.get(Route, route_id)
        |> Repo.preload(:waypoints)
        
        new_waypoints = Enum.map route.waypoints, 
        fn(waypoint) -> 
            Map.from_struct(waypoint) 
            |> Map.take([:id, :lat, :lng])
        end
        
        payload = %{
            id: route.id,
            description: route.description,
            waypoints: new_waypoints
        }
        
        json conn, payload
    end
    
    def create(conn, %{"description" => route_description, "waypoints" => waypoints}) do
        changeset = Route.changeset(%Route{}, %{"description": route_description})
        
        case Repo.insert(changeset) do
            {:ok, route} -> 
                relate_waypoints(route, waypoints)
        end
    end

    def relate_waypoints(route, waypoints) do
        Enum.each waypoints, fn(%{"lat" => lat, "lng" => lng}) -> 
            waypoint_assoc = build_assoc(route, :waypoints, %{lat: lat, lng: lng})

            Repo.insert(waypoint_assoc)
        end
    end
end