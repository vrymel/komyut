import { first, last, slice } from "lodash/fp";
// TODO: read more about runtime and compiletime versions of vue
import Vue from "vue/dist/vue";

const directionsService = new google.maps.DirectionsService;
const directionsDisplay = new google.maps.DirectionsRenderer;

let map = null;
let pageRoutes = null;
let waypointsList;


function init(configPageRoutes) {
    pageRoutes = configPageRoutes
    map = new google.maps.Map(document.getElementById("map"), {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });
    
    directionsDisplay.setMap(map);
    
    attachEventHandlers();
    initWaypointList();
}

const initWaypointList = () => {
    waypointsList = new Vue({
        el: "#waypoints-list",
        data: {
            waypoints: []
        },
        methods: {
            removeWaypoint: function (waypoint){
                this.waypoints = this.waypoints.filter((w) => {
                    return w !== waypoint;
                });
                updateRouteMap();
            }
        }
    });
};

function attachEventHandlers() {
    map.addListener("click", function(data) {
        const { latLng } = data
        const lat = latLng.lat()
        const lng = latLng.lng()
        
        const mapLatLng = new google.maps.LatLng(lat, lng)

        waypointsList.waypoints.push(mapLatLng)
        updateRouteMap();
    });
    
    document.getElementById("submit").addEventListener("click", onSubmitClick)
}

function onSubmitClick(event) {
    const routeDescription = document.getElementById("route_description").value
    
    const payload = {
        "description": routeDescription,
        "waypoints": waypointsList.waypoints.map((w) => w.toJSON())
    }
    
    fetch(pageRoutes.CREATE, {
        "method": "POST",
        "headers": {
            "x-csrf-token": getCSRFToken(), // needed for phoenix 
            "Content-Type": "application/json"
        },
        "body": JSON.stringify(payload),
        "credentials": "same-origin" // needed for x-csrf-token to work
    }).then(() => {
        waypointsList.waypoints = [];
        directionsDisplay.set('directions', null);
        updateRouteMap();
        // alert("Route created!")
    })
}

function getCSRFToken() {
    return document.querySelector("input[name=_csrf_token]").value
}

function updateRouteMap() {
    if (waypointsList.waypoints.length < 2) {
        return;
    }

    const waypoints = waypointsList.waypoints;
    
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