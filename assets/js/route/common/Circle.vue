<template>
</template>

<script>
import Element from "./mixins/Element";
import Ready from "./mixins/Ready";

export default {
  name: "google-map-circle",
  mixins: [Element, Ready],

  initComponent: function() {
    console.log("Circle initComponent", this.mapParent);

    this.mapParent.getMap().then(function(map) {
      var cityCircle = new google.maps.Circle({
        strokeColor: "#FF0000",
        strokeOpacity: 0.8,
        strokeWeight: 2,
        fillColor: "#FF0000",
        fillOpacity: 0.75,
        map: map,
        center: { lat: 8.48379, lng: 124.6509111 },
        radius: 15
      });
    });
  }
};
</script>
