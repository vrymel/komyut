defmodule HelloPhoenix.RouteApiController do
    use HelloPhoenix.Web, :controller
    
    alias HelloPhoenix.Route
    
    def show(conn, %{"id" => route_id}) do
        route = Repo.get(Route, route_id)
        |> Repo.preload(:waypoints)
        
        new_waypoints = Enum.map route.waypoints, 
        fn(waypoint) -> 
            Map.from_struct(waypoint) 
            |> Map.take([:id, :lat, :long])
        end
        
        payload = %{
            id: route.id,
            description: route.description,
            waypoints: new_waypoints
        }
        
        json conn, payload
    end
end