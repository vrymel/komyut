import {origin, destination, between} from "./helper";
import $ from "jquery";

const directionsService = new google.maps.DirectionsService;
const directionsDisplay = new google.maps.DirectionsRenderer;

const $map = $("#map");
const $routesPanel = $(".routes-panel");
const $routeCard = $(".route-card")

const init = () => {
    initMap($map);
    attachEventHandlers();
};


const initMap = ($mapContainer) => {
    var map = new google.maps.Map($mapContainer[0], {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });
    
    directionsDisplay.setMap(map);
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

            $routeCard.find(".description").html(routeData.description);
        })
};


const getRouteData = (routeId) => {
    return fetch(`http://localhost:4000/api/routes/${routeId}`)
    .then((response) => response.json())
};


const setWaypoints = (waypoints) => {
    const originLatLng = origin(waypoints)
    const destinationLatLng = destination(waypoints)
    const betweenLatLng =  between(waypoints)

    directionsService.route({
        origin: new google.maps.LatLng(originLatLng.lat, destinationLatLng.lng),
        destination: new google.maps.LatLng(destinationLatLng.lat, destinationLatLng.lng),
        waypoints: betweenLatLng.map((waypoint) => { 
            return {
                location: new google.maps.LatLng(waypoint.lat, waypoint.lng)
            }
        }),
        travelMode: "DRIVING"
    }, function(response, status) {
        if (status === "OK") {
            directionsDisplay.setDirections(response);
        }
    });
};


export {
    init,
    loadRoute
}