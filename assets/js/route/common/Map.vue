<template>
  <div class="map-component-root">
    <div 
      ref="map" 
      class="map-container"/>
    <slot/>
  </div>
</template>

<script>
export default {
    name: "GoogleMap",

    beforeCreate() {
        this._getMapPromises = [];
    },

    mounted() {
        const map = new google.maps.Map(this.$refs.map, {
            center: new google.maps.LatLng(8.48379, 124.6509111),
            zoom: 16
        });
        map.setOptions({ disableDoubleClickZoom: true });

        this._getMapPromises.forEach(resolve => resolve(map));

        this._mapInstance = map;
    },

    methods: {
        getMap() {
            if (this._mapInstance) {
                return Promise.resolve(this._mapInstance);
            } else {
                return new Promise(resolve => this._getMapPromises.push(resolve));
            }
        }
    }
};
</script>

<style lang="scss" scoped>
.map-component-root {
  position: relative;
  height: 100%;

  > .map-container {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
  }
}
</style>

