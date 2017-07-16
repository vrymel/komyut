function init() {
    var directionsService = new google.maps.DirectionsService;
    var directionsDisplay = new google.maps.DirectionsRenderer;

    var map = new google.maps.Map(document.getElementById("map"), {
        center: new google.maps.LatLng(8.48379, 124.6509111),
        zoom: 16
    });

    directionsDisplay.setMap(map);
    
    directionsService.route({
        origin: new google.maps.LatLng(8.484289, 124.646984),
        destination: new google.maps.LatLng(8.482549, 124.653099),
        waypoints: [
            {
                location: new google.maps.LatLng(8.481052, 124.647991)
            },
            {
                location: new google.maps.LatLng(8.479630, 124.651124)
            }
        ],
        optimizeWaypoints: true,
        travelMode: "DRIVING"
    }, function(response, status) {
        if (status === "OK") {
            directionsDisplay.setDirections(response);
        }
    });
}

export default init;