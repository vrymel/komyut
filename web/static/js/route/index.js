import {origin, destination, between} from "./helper";
import Vue from "vue/dist/vue";

let routePath;
let map;
let originMarker;
let destinationMarker;
let routeCard;
let routesPanel;
let pageRoutes;

const init = (_pageRoutes) => {
	pageRoutes = _pageRoutes;

	initMap(document.querySelector("#map"));

    // initRouteCard();
    initRoutesPanel();
};

const initRouteCard = () => {
	routeCard = new Vue({
		"el": "#route-card",
		"data": {
			"routeData": null
		},
		"methods": {
			"setRouteData": function(routeData) {
				this.routeData = routeData;
			},
			"toRoutePage": function() {

			}
		},
		"mounted": function() {
			initMap(this.$refs.map);
		}
	});
};

const initRoutesPanel = () => {
	routesPanel = new Vue({
		"el": ".routes",
		"methods": {
			"loadRoute": function(routeId) {
				loadRoute(routeId);
			}
		}
	});
};

const initMap = (mapContainer) => {
    map = new google.maps.Map(mapContainer, {
        "center": new google.maps.LatLng(8.48379, 124.6509111),
        "zoom": 16
    });

	routePath = new google.maps.Polyline({
		"strokeColor": '#FF0000',
		"strokeOpacity": 1.0,
		"strokeWeight": 2
	});

	routePath.setMap(map);
};

const loadRoute = (routeId) => {
    getRouteData(routeId)
    .then((routeData) => {
        setWaypoints(routeData.waypoints);
        setMarkers(routeData.waypoints);

        routeCard.setRouteData(routeData);
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
		"label": "A",
        "title": "Origin"
    });
    destinationMarker = new google.maps.Marker({
    	"position": destinationWaypoint,
		"map": map,
		"label": "B",
    	"title": "Destination"
    })
};

const getRouteData = (routeId) => {
    return fetch(`${pageRoutes.ROUTES_API}/${routeId}`)
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
