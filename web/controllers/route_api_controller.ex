defmodule WaypointsDirect.RouteApiController do
    use WaypointsDirect.Web, :controller
    
    alias WaypointsDirect.Route
    alias WaypointsDirect.RouteSegment
    alias WaypointsDirect.RouteWaypoint
    
    def show(conn, %{"id" => route_id}) do
        route = Repo.get(Route, route_id)
        |> Repo.preload(segments: from(s in RouteSegment, order_by: s.description))

        new_segments = Enum.map route.segments, 
        fn(segment) -> 
            Map.from_struct(segment) 
            |> Map.take([:description, :id])
        end
        
        payload = %{
            id: route.id,
            description: route.description,
            segments: new_segments
        }
        
        json conn, payload
    end

    def get_city_routes(conn, _params) do
        query = from r in Route, order_by: [desc: r.is_active, asc: r.description]
        routes = Repo.all(query)
        |> Enum.map(fn(route) ->
                Map.from_struct(route)
                |> Map.take([:description, :id, :is_active])
            end)

        json conn, routes
    end

    def get_segment_waypoints(conn, %{"segment_id" => segment_id}) do
        segment = Repo.get(RouteSegment, segment_id)
        |> Repo.preload(waypoints: from(w in RouteWaypoint, order_by: w.id))

        new_waypoints = Enum.map segment.waypoints, 
        fn(waypoint) -> 
            Map.from_struct(waypoint) 
            |> Map.take([:id, :lat, :lng])
        end

        json conn, new_waypoints
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
