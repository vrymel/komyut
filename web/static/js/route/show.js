import {origin, destination, between} from "./helper";

let map;
let routePath;

const init = (routeId) => {
	const mapContainer = document.getElementById("map");

	getWaypoints(routeId)
	.then((waypoints) => {
		initMap(mapContainer, waypoints);
	})
};

const getWaypoints = (routeId) => {
	return fetch(`http://localhost:4000/api/routes/${routeId}`)
	.then((response) => response.json())
	.then((json) => json.waypoints)
};

const initMap = (mapContainer, waypoints) => {
	const originWaypoint = waypoints[0];
	const destinationWaypoint = waypoints[waypoints.length - 1];

	map = new google.maps.Map(mapContainer, {
		"center": originWaypoint,
		"zoom": 15
	});

	routePath = new google.maps.Polyline({
		"path": waypoints,
		"strokeColor": '#FF0000',
		"strokeOpacity": 1.0,
		"strokeWeight": 2
	});
	routePath.setMap(map);



	const originMarker = new google.maps.Marker({
        "position": originWaypoint,
        "map": map,
        "title": "Origin"
    });
    const destinationMarker = new google.maps.Marker({
    	"position": destinationWaypoint,
    	"map": map,
    	"title": "Destination"
    })
};

export default init;
