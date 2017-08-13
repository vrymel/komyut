import {origin, destination, between} from "./helper";
import $ from "jquery";

const $map = $("#map");
const $routesPanel = $(".routes-panel");
const $routeCard = $(".route-card");
let routePath;
let map;
let originMarker;
let destinationMarker;

const init = () => {
    initMap($map);
    attachEventHandlers();
};

const initMap = ($mapContainer) => {
    map = new google.maps.Map($mapContainer[0], {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 14
    });

	routePath = new google.maps.Polyline({
		strokeColor: '#FF0000',
		strokeOpacity: 1.0,
		strokeWeight: 2
	});

	routePath.setMap(map);
};

const attachEventHandlers = () => {
    $routesPanel.on("click", ".route-item", function() {
        var $this = $(this);
        var routeId = $this.data("route-id");

        loadRoute(routeId);
    });
};

const loadRoute = (routeId) => {
    getRouteData(routeId)
    .then((routeData) => {
        setWaypoints(routeData.waypoints);
        setMarkers(routeData.waypoints);

        $routeCard.find(".description").html(routeData.description);
    })
};

const setMarkers = (waypoints) => {
	const originWaypoint = waypoints[0];
	const destinationWaypoint = waypoints[waypoints.length - 1];

	map.setCenter(originWaypoint);

	!!originMarker && originMarker.setMap(null);
	!!destinationMarker && destinationMarker.setMap(null);

	originMarker = new google.maps.Marker({
        "position": originWaypoint,
        "map": map,
        "title": "Origin"
    });
    destinationMarker = new google.maps.Marker({
    	"position": destinationWaypoint,
    	"map": map,
    	"title": "Destination"
    })
};

const getRouteData = (routeId) => {
    return fetch(`http://localhost:4000/api/routes/${routeId}`)
    .then((response) => response.json())
};

const setWaypoints = (waypoints) => {
	const path = routePath.getPath();
	while(path.length)
		path.removeAt(0);

	for(var i = 0; i < waypoints.length; i++) {
		const {lat, lng} = waypoints[i];
		const mapLatLng = new google.maps.LatLng(lat, lng)

		path.push(mapLatLng);
	}
};


export {
    init,
    loadRoute
}
