import { first, last, slice } from "lodash/fp"

const directionsService = new google.maps.DirectionsService
const directionsDisplay = new google.maps.DirectionsRenderer
const waypoints = []

function init() {
    const map = new google.maps.Map(document.getElementById("map"), {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });
    
    directionsDisplay.setMap(map);
    
    map.addListener("click", function(data) {
        const { latLng } = data;
        const lat = latLng.lat();
        const lng = latLng.lng();

        const mapLatLng = new google.maps.LatLng(lat, lng);

        waypoints.push(mapLatLng);
        updateRouteMap();
    });
}

function updateRouteMap() {
    if (waypoints.length < 2) 
        return;

    const f = first(waypoints)
    const l = last(waypoints);
    const m = slice(1, waypoints.length - 1)(waypoints);

    directionsService.route({
        origin: f,
        destination: l,
        waypoints: m.map((mapLatLong) => { 
            return {
                location: mapLatLong 
            }
        }),
        travelMode: "DRIVING"
    }, function(response, status) {
        if (status === "OK") {
            directionsDisplay.setDirections(response);
        }
    });
    
}

export default init;