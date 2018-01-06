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
      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">Control Modes</h6>
          
          <div class="my-3">
            <p class="card-subtitle text-muted font-weight-light">Intersection</p>
            <button 
              class="btn"
              :class="{ 'btn-dark': show_intersections, 'btn-secondary': !show_intersections }" 
              @click="onShowIntersections">
              <i 
                class="fa"
                :class="{ 'fa-eye-slash': !show_intersections, 'fa-eye': show_intersections }"/>
            </button>
            <div class="btn-group">
              <button
              class="btn btn-secondary">
                <i class="fa fa-plus"/>
              </button>
              <button
              class="btn btn-secondary">
                <i class="fa fa-minus"/>
              </button>
            </div>
          </div>

          <div class="my-3">
            <p class="card-subtitle text-muted font-weight-light">Connect</p>
            <div class="btn-group">
              <button
              class="btn btn-secondary">
                <i class="fa fa-plus"/>
              </button>
              <button
              class="btn btn-secondary">
                <i class="fa fa-eraser"/>
              </button>
            </div>
          </div>
        </div>
      </div>
      
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

const getIntersections = async () => {
    const response = await axios.get(api_paths.INDEX);

    return response.data;
};

export default {
    name: "AppNewRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle
    },
    data() {
        return {
            show_intersections: false,
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
        },
        async onShowIntersections() {
            if (this.show_intersections) {
                this.intersections = [];
                this.show_intersections = false;
            } else {
                const result = await getIntersections();
                if (!result.success) {
                    alert("Could not fetch intersections at this time."); // TODO: use something beautiful
                    return false;
                }
            
                this.intersections = result.intersections;
                this.show_intersections = true;
            }
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

