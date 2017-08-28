defmodule HelloPhoenix.RouteApiController do
    use HelloPhoenix.Web, :controller
    
    alias HelloPhoenix.Route
    alias HelloPhoenix.RouteSegment
    
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
    
    def create(conn, %{"description" => route_description, "route_id" => route_id, "waypoints" => waypoints}) do
        route = Repo.get!(Route, route_id)
        route_segment_assoc = build_assoc(route, :segments, %{"description": route_description})
        
        case Repo.insert(route_segment_assoc) do
            {:ok, route_segment} -> 
                relate_waypoints(route_segment, waypoints)
                json conn, %{
                    "success": true
                }
        end
    end

    def relate_waypoints(route_segment, waypoints) do
        Enum.each waypoints, fn(%{"lat" => lat, "lng" => lng}) -> 
            waypoint_assoc = build_assoc(route_segment, :waypoints, %{lat: lat, lng: lng})

            Repo.insert(waypoint_assoc)
        end
    end
end