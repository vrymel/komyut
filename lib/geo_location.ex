defmodule WaypointsDirect.GeoLocation do
    @moduledoc """
    Provides calculation of a source geo-point

    Reference: 
        Source: http://janmatuschek.de/LatitudeLongitudeBoundingCoordinates
        Mirror: https://docs.google.com/document/d/1a6ZCIJyK1ZpEmD33tamfqzVpqN6Fcanxm1CENfeoKm0/edit?usp=drive_web
    """
    alias WaypointsDirect.GeoPoint

    # approximate radius of the Earth in km
    @earth_radius 6371

    def calculate_bounding_coordinates(%GeoPoint{latitude: _, longitude: _} = geo_point, distance) do
        radius = angular_radius distance

        latitude_bounds = get_latitude_bounds(geo_point, radius)
        longitude_bounds = get_longitude_bounds(geo_point, radius)

        min = %GeoPoint{latitude: latitude_bounds.min, longitude: longitude_bounds.min}
        max = %GeoPoint{latitude: latitude_bounds.max, longitude: longitude_bounds.max}

        %{min: min, max: max}
    end

    defp angular_radius(distance) do
        distance / @earth_radius
    end

    defp get_latitude_bounds(%GeoPoint{latitude: latitude}, radius) do
        min = latitude - radius
        max = latitude + radius

        %{min: min, max: max}
    end

    defp get_longitude_bounds(%GeoPoint{latitude: latitude, longitude: longitude}, radius) do
        delta_longitude = :math.asin(:math.sin(radius) / :math.cos(latitude))

        min = longitude - delta_longitude
        max = longitude + delta_longitude

        %{min: min, max: max}
    end
end