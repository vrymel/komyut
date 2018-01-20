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

        <google-map-polyline 
          v-if="selectedIntersectionPoints.length"
          :name="'intersectionPath'"
          :visible="!showRoutePath"
          :path="selectedIntersectionPoints" />

        <google-map-polyline
          v-if="routePath.length"
          :name="'routePath'"
          :visible="showRoutePath"
          :path="routePath" />
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

          <div class="my-3">
            <button
              class="btn btn-light"
              @click="resetForm">
            Reset</button>
            <toggle-button
              :value="'value'"
              :active="showRoutePath"
              @click="snapToRoads">
              <i class="fa fa-road"/>
              Snap to road
            </toggle-button>
          </div>
        </div>
      </div>

      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">Route Name</h6>

          <input 
            v-model="routeName"
            type="text" 
            class="form-control"
            placeholder="Enter route name">
        </div>
      </div>

      <div class="m-2 card">
        <div class="card-body">
          <button 
            class="btn btn-primary"
            @click="saveRoute">
            <i class="fa fa-save"/>
          Save</button>
        </div>
      </div>
      
    </div>
  </div>
</template>

<script>
import axios from "axios";
import qs from "query-string";

import api_paths from "../api_paths";
import ToggleButton from "./ToggleButton";

// google map components
import Map from "../common/Map";
import Circle from "../common/Circle";
import Polyline from "../common/Polyline";

const doPersistIntersection = async (intersection) => {
    const response = await axios.post(api_paths.CREATE, intersection);
    const {data} = response;
    
    return data;
};

const getIntersections = async () => {
    const response = await axios.get(api_paths.INDEX);

    return response.data;
};

const doPersistRoute = async ({routeName, routeEdges}) => {
    const response = await axios.post(api_paths.CREATE_ROUTE, { 
        route_name: routeName,
        raw_route_edges: routeEdges 
    });

    return response.data;
};

// form route edges based on the selected intersections array
// the pairing of intersection to be the from and end intersections
// is based on the array. `current index` will be paired with `currect index + 1`
// last iteration will be whatever the `last index - 1` is. we stop before
// the last index because that is our only last pair. if we stop ON the last index
// itself, the last index will not have any pair
const formRouteEdges = (selectedIntersectionPoints) => {
    const intersectionsLength = selectedIntersectionPoints.length;
    const arrayLastIndex = intersectionsLength - 1;
    const routeEdges = [];

    let start = 0;
    let end = 0;
    for(let i = 0; (end < arrayLastIndex); i++) {
        start = i;
        end = i + 1;
                
        const startIntersection = Object.assign({}, selectedIntersectionPoints[start]);
        const endIntersection = Object.assign({}, selectedIntersectionPoints[end]);

        routeEdges.push({
            start: startIntersection,
            end: endIntersection
        });
    }

    return routeEdges;
};

const snapToRoads = async (waypoints) => {
    var pathValues = waypoints.map((w) => {
        const {lat, lng} = w;

        return `${lat},${lng}`;
    });

    const params = {
        interpolate: true,
        key: GOOGLE_MAP_API_KEY,
        path: pathValues.join('|')
    };
    const url = `https://roads.googleapis.com/v1/snapToRoads?${qs.stringify(params)}`;

    return axios.get(url)
        .then((response) => response.data)
        .then(({snappedPoints}) => {
            return snappedPoints.map((point) => {
                return new google.maps.LatLng(point.location.latitude, point.location.longitude);
            });
        });
};

const controlModes = {
    addIntersection: 10,
    removeIntersection: 20,
    addEdge: 30,
    removeEdge: 40
};

export default {
    name: "AppNewRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle,
        "google-map-polyline": Polyline,
        "toggle-button": ToggleButton
    },
    data() {
        return {
            showIntersections: false,
            intersections: [],
            controlModes: controlModes,
            activeControlMode: null,
            selectedIntersectionPoints: [],
            routePath: [],
            showRoutePath: false,
            routeName: ""
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
        onCircleClick(googleData) {
            const isAddEdgeMode = this.isActiveControlMode(controlModes.addEdge);
            const isRemoveEdgeMode = this.isActiveControlMode(controlModes.removeEdge);

            if (isAddEdgeMode) {
                this.storeIntersectionPoint(googleData);
            } else if (isRemoveEdgeMode) {
                this.removeStoredIntersectionPoint(googleData);
            }
        },
        storeIntersectionPoint({id, lat, lng}) {
            const intersection = {id, lat, lng};
            const arrayLength = this.selectedIntersectionPoints.length;
            const arrayNotEmpty = !!arrayLength;
            let notDuplicateFromLastItemAdded = true;

            // check if the last item added is not the same
            // with the currently clicked circle
            if (arrayNotEmpty) {
                const lastIndex = arrayLength - 1;
                const lastIntersectionItem = this.selectedIntersectionPoints[lastIndex];

                notDuplicateFromLastItemAdded = lastIntersectionItem.id !== id;
            } 

            if (notDuplicateFromLastItemAdded) {
                this.selectedIntersectionPoints.push(intersection);
            } 
        },
        removeStoredIntersectionPoint({lat, lng}) {
            this.selectedIntersectionPoints = this.selectedIntersectionPoints.filter((intersection) => {
                const sameLat = intersection.lat === lat;
                const sameLng = intersection.lng === lng;

                return !(sameLat && sameLng);
            });
        },
        async persistIntersection({ latLng }) {
            const lat = latLng.lat();
            const lng = latLng.lng();

            const result = await doPersistIntersection({lat, lng});
            if (!result.success) {
                // TODO: use something beautiful
                alert("Could not add intersection");
            } else {
                this.intersections.push({lat, lng, id: result.intersection_id});
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
        async saveRoute() {
            const routeEdges = formRouteEdges(this.selectedIntersectionPoints);

            const result = await doPersistRoute({
                routeEdges,
                routeName: this.routeName
            });

            if (result.success) {
                this.resetForm();
            } else {
                alert("something wen't wrong while saving...");
            }
        },
        resetForm() {
            this.selectedIntersectionPoints = [];
            this.routeName = "";
        },
        async snapToRoads() {
            if (!this.showRoutePath) {
                const latlng = await snapToRoads(this.selectedIntersectionPoints);

                this.routePath = latlng;
                this.showRoutePath = true;
            } else {
                this.showRoutePath = false;
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

