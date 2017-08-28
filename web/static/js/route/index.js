import { origin, destination, between } from "./helper";
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

	initRouteContextPanel();
};

const initRouteContextPanel = () => {
	routesPanel = new Vue({
		el: "#route-context",
		data: {
			description: "Select a route",
			segments: [],
			loadedSegment: null
		},
		methods: {
			setContext: function (routeData) {
				this.description = routeData.description;
				this.segments = routeData.segments;
			},
			loadRoute: function (routeId) {
				const self = this;

				fetch(`${pageRoutes.ROUTES_API}/${routeId}`)
					.then((response) => response.json())
					.then((routeData) => {
						self.setContext(routeData);

						self.loadWaypoints(routeData.segments[0]);
					});
			},
			loadWaypoints: function (segment) {
				const self = this;

				fetch(`${pageRoutes.ROUTES_API}/get_segment_waypoints/${segment.id}`)
					.then((response) => response.json())
					.then((waypoints) => {
						setWaypoints(waypoints);
						setMarkers(waypoints);

						self.loadedSegment = segment;
					});
			}
		}
	});

	window.routesPanel = routesPanel;
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
};

const setWaypoints = (waypoints) => {
	const path = routePath.getPath();
	while (path.length)
		path.removeAt(0);

	for (var i = 0; i < waypoints.length; i++) {
		const { lat, lng } = waypoints[i];
		const mapLatLng = new google.maps.LatLng(lat, lng)

		path.push(mapLatLng);
	}
};


export {
	init
}
