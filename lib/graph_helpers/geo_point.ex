defmodule WaypointsDirect.GeoPoint do
    defstruct lat: nil, lng: nil

    def from_degrees(%WaypointsDirect.GeoPoint{:lat => lat, :lng => lng}) do
        %WaypointsDirect.GeoPoint{lat: to_radian_value(lat), lng: to_radian_value(lng)}
    end

    def to_degrees(%WaypointsDirect.GeoPoint{:lat => lat, :lng => lng}) do
        %WaypointsDirect.GeoPoint{lat: to_degree_value(lat), lng: to_degree_value(lng)}
    end

    defp to_radian_value(degrees) do 
        (degrees * :math.pi) / 180
    end

    defp to_degree_value(radians) do
        radians * 180 / :math.pi
    end
end