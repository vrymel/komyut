import { first, last, slice } from "lodash/fp";
// TODO: read more about runtime and compiletime versions of vue
import Vue from "vue/dist/vue";

const directionsService = new google.maps.DirectionsService;
const directionsDisplay = new google.maps.DirectionsRenderer;

let map = null;
let pageRoutes = null;
let waypointsList;
let routhPath;


function init(configPageRoutes) {
    pageRoutes = configPageRoutes;

    map = new google.maps.Map(document.getElementById("map"), {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });
    map.setOptions({disableDoubleClickZoom: true });
    
    routhPath = new google.maps.Polyline({
		strokeColor: '#FF0000',
		strokeOpacity: 1.0,
		strokeWeight: 2
	});
    
	routhPath.setMap(map);
    
    attachEventHandlers();
    initWaypointList();
}

const initWaypointList = () => {
    waypointsList = new Vue({
        el: "#waypoints-list",
        data: {
            waypoints: []
        },
        computed: {
            displayWaypoints: function() {
                var copy = this.waypoints.slice();

                return copy.reverse();
            }
        },
        methods: {
            removeWaypoint: function (removeIndex){
                this.waypoints = this.waypoints.filter((w, index) => {
                    return removeIndex !== index;
                });
                
                const path = routhPath.getPath();
                path.removeAt(removeIndex);
            }
        }
    });
};

function attachEventHandlers() {
    map.addListener("dblclick", function(event) {
        const rPath = routhPath.getPath();
        const waypointsLimit = 100; // google's snap-to-road api limits 100 waypoints per request
        const waypointsLimitReached = rPath.getLength() === waypointsLimit;

        if (waypointsLimitReached) {
            alert("Waypoints limit reached! You can only create 100 waypoints for a given route.");
            return;
        }

        rPath.push(event.latLng);
        
        
        waypointsList.waypoints.push(event.latLng);
    });
    
    document.getElementById("submit").addEventListener("click", onSubmitClick)
}

function onSubmitClick(event) {
    const routeDescription = document.getElementById("route_description").value;
    const routeId = document.getElementById("route_route_id").value;
    const payload = {
        description: routeDescription,
        waypoints: waypointsList.waypoints.map((w) => w.toJSON()),
        route_id: routeId
    };
    
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
        
        const path = routhPath.getPath();
        while(path.length)
            path.removeAt(0)
        
        alert("Route created!");
    })
}

function getCSRFToken() {
    return document.querySelector("input[name=_csrf_token]").value
}

export default init;
