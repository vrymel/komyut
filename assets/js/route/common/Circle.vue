<template>
</template>

<script>
export default {
  name: "google-map-circle",

  created() {
    if (this.$parent) {
      this.mapParent = this.$parent;
    }
  },

  async mounted() {
      const map = await this.mapParent.getMap();

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
  }
};
</script>
