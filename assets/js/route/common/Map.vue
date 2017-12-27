<template>
  <div ref="map" class="map-container"></div>
</template>

<script>
export default {
  name: "google-map",
  mounted: function () {
    const map = new google.maps.Map(this.$refs.map, {
      center: new google.maps.LatLng(8.48379, 124.6509111),
      zoom: 16
    });
    map.setOptions({ disableDoubleClickZoom: true });
  }
};
</script>

<style lang="scss" scoped>
    .map-container {
        height: 100%;
    }
</style>

