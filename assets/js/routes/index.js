import {
	origin,
	destination,
	between
} from "./helper";
import Vue from "vue/dist/vue";
import _ from "lodash";
import qs from "query-string";

let routePath;
let map;
let originMarker;
let destinationMarker;
let routeCard;
let routesPanel;
let pageRoutes;
let citySelectModal;
let routeSelectModal;

const init = (_pageRoutes) => {
	pageRoutes = _pageRoutes;

	initMap(document.querySelector("#map"));
	initRouteContextPanel();
	initCitySelectModal();
	initRouteSelectModal();
};

const initCitySelectModal = () => {
	citySelectModal = new Vue({
		el: "#city-select-modal",
		data: {
			visible: false
		},
		methods: {
			close: function () {
				this.visible = false;
			},
			show: function () {
				this.visible = true;
			}
		}
	});
};

const initRouteSelectModal = () => {
	routeSelectModal = new Vue({
		el: "#route-select-modal",
		data: {
			visible: false,
			routes: [],
			activeRouteId: null
		},
		methods: {
			close: function () {
				this.visible = false;
			},
			show: function () {
				const self = this;

				this.visible = true;

				fetch(`${pageRoutes.ROUTES_API}/get_city_routes/${routesPanel.cityId}`)
					.then((response) => response.json())
					.then((routesData) => {
						self.routes = routesData;
					});
			},
			selectRoute: function (routeId) {
				this.activeRouteId = routeId;

				routesPanel.loadRoute(routeId)
			}
		}
	});
};

const initRouteContextPanel = () => {
	routesPanel = new Vue({
		el: "#route-context",
		data: {
			description: "Select a route",
			segments: [],
			loadedSegment: null,
			cityId: null,
			routeId: null
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

						if (!!routeData.segments[0])
							self.loadWaypoints(routeData.segments[0]);
						else {
							setWaypoints([]);
							setMarkers([]);
						}
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
			},
			showCitySelectModal: function () {
				citySelectModal.show();
			},
			showRouteSelectModal: function () {
				routeSelectModal.show();
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
		"strokeOpacity": 0.5,
		"strokeWeight": 5
	});

	routePath.setMap(map);
};

const setMarkers = (waypoints) => {
	const originWaypoint = waypoints[0];
	const destinationWaypoint = waypoints[waypoints.length - 1];

	map.setCenter(originWaypoint);

	!!originMarker && originMarker.setMap(null);
	!!destinationMarker && destinationMarker.setMap(null);

	if (!!originWaypoint) {
		originMarker = new google.maps.Marker({
			"position": originWaypoint,
			"map": map,
			"label": "A",
			"title": "Origin"
		});
	}
	if (!!destinationWaypoint) {
		destinationMarker = new google.maps.Marker({
			"position": destinationWaypoint,
			"map": map,
			"label": "B",
			"title": "Destination"
		})
	}
};

const getRouteData = (routeId) => {};

const setWaypoints = (waypoints) => {
	const path = routePath.getPath();
	while (path.length)
		path.removeAt(0);

	var pathValues = _.map(waypoints, (w) => {
		const {
			lat,
			lng
		} = w;

		return `${lat},${lng}`;
	});

	const params = {
		interpolate: true,
		key: GOOGLE_MAP_API_KEY,
		path: pathValues.join('|')
	};
	const url = `https://roads.googleapis.com/v1/snapToRoads?${qs.stringify(params)}`;

	fetch(url)
		.then((response) => response.json())
		.then((data) => {
			for (var i = 0; i < data.snappedPoints.length; i++) {
				var latlng = new google.maps.LatLng(
					data.snappedPoints[i].location.latitude,
					data.snappedPoints[i].location.longitude);

				path.push(latlng);
			}
		});
};


export {
	init
}
