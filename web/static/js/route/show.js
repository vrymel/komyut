const directionsService = new google.maps.DirectionsService;
const directionsDisplay = new google.maps.DirectionsRenderer;

const init = (routeId) => {
    const mapContainer = document.getElementById("map");

    getWaypoints(routeId)
        .then((waypoints) => {
            initMap(mapContainer, waypoints)
        })

    initMap(mapContainer);
};

const getWaypoints = (routeId) => {
    return fetch(`http://localhost:4000/api/routes/${routeId}`)
        .then((response) => response.json())
        .then((json) => json.waypoints)
};

const initMap = (mapContainer, waypoints) => {
    var map = new google.maps.Map(mapContainer, {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });
    
    directionsDisplay.setMap(map);

    directionsService.route({
        origin: new google.maps.LatLng(8.484289, 124.646984),
        destination: new google.maps.LatLng(8.484532, 124.647154),
        waypoints: waypoints.map((waypoint) => { 
            return {
                location: new google.maps.LatLng(waypoint.lat, waypoint.long)
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