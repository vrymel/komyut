defmodule WaypointsDirect.GeoPoint do
    defstruct latitude: nil, longitude: nil

    def from_degrees(%WaypointsDirect.GeoPoint{:latitude => lat, :longitude => lng}) do
        %WaypointsDirect.GeoPoint{latitude: to_radian_value(lat), longitude: to_radian_value(lng)}
    end

    def to_degrees(%WaypointsDirect.GeoPoint{:latitude => lat, :longitude => lng}) do
        %WaypointsDirect.GeoPoint{latitude: to_degree_value(lat), longitude: to_degree_value(lng)}
    end

    defp to_radian_value(degrees) do 
        (degrees * :math.pi) / 180
    end

    defp to_degree_value(radians) do
        radians * 180 / :math.pi
    end
end