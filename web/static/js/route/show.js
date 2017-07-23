import {origin, destination, between} from "./helper"

const directionsService = new google.maps.DirectionsService
const directionsDisplay = new google.maps.DirectionsRenderer

const init = (routeId) => {
    const mapContainer = document.getElementById("map");

    getWaypoints(routeId)
        .then((waypoints) => {
            initMap(mapContainer, waypoints)
        })
};

const getWaypoints = (routeId) => {
    return fetch(`http://localhost:4000/api/routes/${routeId}`)
        .then((response) => response.json())
        .then((json) => json.waypoints)
};

function initMap(mapContainer, waypoints) {
    var map = new google.maps.Map(mapContainer, {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });
    
    directionsDisplay.setMap(map);

    const originLatLng = origin(waypoints)
    const destinationLatLng = destination(waypoints)
    const betweenLatLng = between(waypoints)

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

export default init;