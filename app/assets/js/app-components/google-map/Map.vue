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

    props: {
        center: {
            type: Object,
            required: true
        },
        zoom: {
            type: Number,
            default: () => 16
        }
    },

    watch: {
        "center": "updateCenter",
        "zoom": "updateZoom"
    },

    beforeCreate() {
        this._getMapPromises = [];
    },

    mounted() {
        const map = new google.maps.Map(this.$refs.map, {
            center: this.center,
            zoom: this.zoom
        });
        map.setOptions({ disableDoubleClickZoom: true });

        this._getMapPromises.forEach(resolve => resolve(map));

        this._mapInstance = map;
        this._mapInstance.addListener("click", (...args) => this.$emit("click", ...args));
    },

    methods: {
        getMap() {
            if (this._mapInstance) {
                return Promise.resolve(this._mapInstance);
            } else {
                return new Promise(resolve => this._getMapPromises.push(resolve));
            }
        },
        updateCenter() {
            this._mapInstance.setOptions({center: this.center});
        },
        updateZoom() {
            this._mapInstance.setOptions({zoom: this.zoom});
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

