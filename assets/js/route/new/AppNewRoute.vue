<template>
  <div class="app-new-route">
    <div class="map">
      <google-map
      @click="onMapClick">
        <google-map-circle 
          v-for="(intersection, index) in intersections"
          :key="index"
          :center="intersection"/>
      </google-map>
    </div>
    <div class="sidebar">
      <button @click="remove">Remove</button>
    </div>
  </div>
</template>

<script>
import axios from "axios";

import api_paths from "../api_paths";
import Map from "../common/Map";
import Circle from "../common/Circle";

const persistIntersection = (intersection) => {
    axios.post(api_paths.CREATE, intersection)
        .then(({data}) => {
            if (!data.success) {
                // TODO: use something beautiful
                alert("Could not add intersection");
            }
        })
};

export default {
    name: "AppNewRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle
    },
    data() {
        return { 
            intersections: []
        };
    },
    methods: {
        remove() {
            this.attach = !this.attach;
        },
        onMapClick({ latLng }) {
            const lat = latLng.lat();
            const lng = latLng.lng();

            this.intersections.push({lat, lng});

            persistIntersection({lat, lng});
        }
    }
};
</script>

<style lang="scss" scoped>
.app-new-route {
  display: flex;
  width: 100%;

  .map {
    flex: 3;
  }

  .sidebar {
    flex: 1;
  }
}
</style>

