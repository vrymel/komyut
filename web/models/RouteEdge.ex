defmodule WaypointsDirect.RouteEdge do
    use WaypointsDirect.Web, :model

    alias WaypointsDirect.Intersection
    alias WaypointsDirect.Route

    schema "route_edges" do
        # reference doing foreign keys on the same model: https://elixirforum.com/t/add-two-foreign-key-columns-that-reference-the-same-table/1274/16
        # define here that the column :from_intersection and :to_intersection_id is a foreign key
        # that points to the `Intersection` model. 
        # a corresponding association is also needed in the `Intersection` model for this (see Intersection)
        belongs_to :from_intersection, Intersection, foreign_key: :from_intersection_id
        belongs_to :to_intersection, Intersection, foreign_key: :to_intersection_id
        belongs_to :route, Route # without defining foreign_key, it will default to the name with an _id suffix, in this case route_id

        timestamps()
    end

    def changeset(route_edge, params \\ %{}) do
        route_edge
    end
end