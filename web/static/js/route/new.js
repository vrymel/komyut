import { first, last, slice } from "lodash/fp"

let map = null
const directionsService = new google.maps.DirectionsService
const directionsDisplay = new google.maps.DirectionsRenderer
const waypoints = []
let pageRoutes = null

function init(configPageRoutes) {
    pageRoutes = configPageRoutes
    map = new google.maps.Map(document.getElementById("map"), {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });
    
    directionsDisplay.setMap(map);
    
    attachEventHandlers();
}

function attachEventHandlers() {
    map.addListener("click", function(data) {
        const { latLng } = data
        const lat = latLng.lat()
        const lng = latLng.lng()
        
        const mapLatLng = new google.maps.LatLng(lat, lng)
        
        waypoints.push(mapLatLng)
        updateRouteMap()   // test
    });
    
    document.getElementById("submit").addEventListener("click", onSubmitClick)
}

function onSubmitClick(event) {
    const routeDescription = document.getElementById("route_description").value
    
    const payload = {
        "description": routeDescription,
        "waypoints": waypoints.map((w) => w.toJSON())
    }
    
    fetch(pageRoutes.CREATE, {
        "method": "POST",
        "headers": {
            "x-csrf-token": getCSRFToken(), // needed for phoenix 
            "Content-Type": "application/json"
        },
        "body": JSON.stringify(payload),
        "credentials": "same-origin" // needed for x-csrf-token to work
    }).then(console.log)
}

function getCSRFToken() {
    return document.querySelector("input[name=_csrf_token]").value
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