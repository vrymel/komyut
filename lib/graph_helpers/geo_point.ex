defmodule WaypointsDirect.GeoPoint do
    defstruct latitude: nil, longitude: nil

    def from_degrees(latitude, longitude) do
        %WaypointsDirect.GeoPoint{latitude: to_radian(latitude), longitude: to_radian(longitude)}
    end

    defp to_radian(degrees) do 
        (degrees * :math.pi) / 180
    end
end