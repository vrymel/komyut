<template>
  <div class="app-new-route">
    <div class="map">
      <google-map
      @click="onMapClick">
        <google-map-circle 
          v-for="(intersection, index) in intersections"
          :key="index"
          :center="intersection"
          @click="onCircleClick"/>
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
              :class="{ 'btn-dark': showIntersections, 'btn-secondary': !showIntersections }" 
              @click="onShowIntersections">
              <i 
                class="fa"
                :class="{ 'fa-eye-slash': !showIntersections, 'fa-eye': showIntersections }"/>
            </button>
            <div class="btn-group">
              <toggle-button
                :value="controlModes.addIntersection.toString()"
                :active="isActiveControlMode(controlModes.addIntersection)"
                @click="onControlModeChange">
                <i class="fa fa-plus"/>
              </toggle-button>
              <toggle-button
                :value="controlModes.removeIntersection.toString()"
                :active="isActiveControlMode(controlModes.removeIntersection)"
                @click="onControlModeChange">
                <i class="fa fa-eraser"/>
              </toggle-button>
            </div>
          </div>

          <div class="my-3">
            <p class="card-subtitle text-muted font-weight-light">Connect</p>
            <div class="btn-group">
              <toggle-button
                :value="controlModes.addEdge.toString()"
                :active="isActiveControlMode(controlModes.addEdge)"
                @click="onControlModeChange">
                <i class="fa fa-plus"/>
              </toggle-button>
              <toggle-button
                :value="controlModes.removeEdge.toString()"
                :active="isActiveControlMode(controlModes.removeEdge)"
                @click="onControlModeChange">
                <i class="fa fa-eraser"/>
              </toggle-button>
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
import ToggleButton from "./ToggleButton";

const doPersistIntersection = async (intersection) => {
    const response = await axios.post(api_paths.CREATE, intersection);
    const {data} = response;
    
    return data;
};

const getIntersections = async () => {
    const response = await axios.get(api_paths.INDEX);

    return response.data;
};

const controlModes = {
    addIntersection: 10,
    removeIntersection: 20,
    addEdge: 30,
    removeEdge: 40
};

const selectedIntersectionPoints = [];

export default {
    name: "AppNewRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle,
        "toggle-button": ToggleButton
    },
    data() {
        return {
            showIntersections: false,
            intersections: [],
            controlModes: controlModes,
            activeControlMode: null
        };
    },
    methods: {
        remove() {
            this.attach = !this.attach;
        },
        onMapClick(googleData) {
            const isAddIntersectionMode = this.isActiveControlMode(controlModes.addIntersection);

            if (isAddIntersectionMode) {
                this.persistIntersection(googleData);
            }
        },
        async persistIntersection({ latLng }) {
            const lat = latLng.lat();
            const lng = latLng.lng();

            const result = await doPersistIntersection({lat, lng});
            if (!result.success) {
                // TODO: use something beautiful
                alert("Could not add intersection");
            } else {
                this.intersections.push({lat, lng});
            }
        },
        async onShowIntersections() {
            if (this.showIntersections) {
                this.intersections = [];
                this.showIntersections = false;
            } else {
                const result = await getIntersections();
                if (!result.success) {
                    alert("Could not fetch intersections at this time."); // TODO: use something beautiful
                    return false;
                }
            
                this.intersections = result.intersections;
                this.showIntersections = true;
            }
        },
        onControlModeChange(mode) {
            const _mode = parseInt(mode);
            // turn off active state if button is clicked again
            if (this.isActiveControlMode(_mode)) {
                this.activeControlMode = null;
            } else {
                this.activeControlMode = _mode;
            }
        },
        isActiveControlMode(mode) {
            return this.activeControlMode === mode;
        },
        onCircleClick({lat, lng}) {
            const intersection = {lat, lng};
            const arrayLength = selectedIntersectionPoints.length;
            const arrayNotEmpty = !!arrayLength;
            let notDuplicateFromLastItemAdded = true;

            // check if the last item added is not the same
            // with the currently clicked circle
            if (arrayNotEmpty) {
                const lastIndex = arrayLength - 1;
                const lastIntersectionItem = selectedIntersectionPoints[lastIndex];

                const sameLat = lastIntersectionItem.lat === lat;
                const sameLng = lastIntersectionItem.lng === lng;
                notDuplicateFromLastItemAdded = !sameLat && !sameLng;
            } 

            if (notDuplicateFromLastItemAdded) {
                selectedIntersectionPoints.push(intersection);
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

