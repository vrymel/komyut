<template>
  <div class="app-index-route">
    <div class="map-container">
      <google-map
      @click="mapClick">
        <google-map-circle 
          v-for="(intersection) in debugIntersections"
          :key="intersection.id"
          :center="intersection"/>

        <google-map-polyline 
          v-if="routePath.length"
          :name="'routePath'"
          :path="routePath" />

        <google-map-marker
          v-if="!isObjectEmpty(searchFromCoordinate)"
          :position="searchFromCoordinate"
          :label="'A'" />

        <google-map-marker
          v-if="!isObjectEmpty(searchToCoordinate)"
          :position="searchToCoordinate"
          :label="'B'" />
      </google-map>
    </div>

    <div 
    class="sidebar">
      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">Debug controls</h6>
          
          <div class="card-block">
            <toggle-button
              :value="'debugShowIntersections'"
              :active="debugShowIntersections"
              @click="debugOnShowIntersections">
              <i 
                class="fa"
                :class="{ 'fa-eye-slash': !showIntersections, 'fa-eye': showIntersections }"/>
            </toggle-button>
          </div>
        </div>
      </div>

      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">City</h6>

          <div class="card-text">
            Cagayan de Oro City
          </div>
        </div>

        <div 
          class="m-2 card route-select"
          @click="routeSelect">
          <div class="card-body">
            <h6 class="card-title">Route</h6>

            <div 
              class="card-text"
              v-if="currentRoute">
              {{ currentRoute.description }}
            </div>
            <div 
              v-else
              class="card-text no-route-selected">No route selected</div>
          </div>
        </div>
      </div>

      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">Search route</h6>
          
          <div class="card-block my-2">
            <div class="card">
              <div class="card-body">
                <h6 class="card-title">From (A)</h6>
                <address-display :coordinates="searchFromCoordinate"/>
              </div>
            </div>
          </div>

          <div class="card-block my-2">
            <div class="card">
              <div class="card-body">
                <h6 class="card-title">To (B)</h6>
                <address-display :coordinates="searchToCoordinate"/>
              </div>
            </div>
          </div>

          <div class="card-block mt-4">
            <button 
              class="btn btn-primary"
              @click="searchPath">Search</button>
          </div>
        </div>
      </div>
    </div>

    <route-select-dialog
      v-show="showSelectRouteDialog"
      :routes="routes"
      @close="closeSelectRouteDialog"
      @routeSelected="routeSelected"/>
  </div>
</template>

<script>
import axios from "axios";
import { isEmpty } from "lodash";

import api_paths from "../api_paths";
import { APP_LOGO } from "../globals";
import { snapToRoads } from "../services";
import ToggleButton from "../common/ToggleButton";

import Map from "../common/Map";
import Circle from "../common/Circle";
import Polyline from "../common/Polyline";
import Marker from "../common/Marker";

import RouteSelectDialog from "./RouteSelectDialog";
import AddressDisplay from "./AddressDisplay";

const getRoutes = async () => {
    try {
        const result = await axios.get(api_paths.ROUTE_API_INDEX);

        return result.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};

const getRoute = async (routeId) => {
    try {
        const result = await axios.get(`${api_paths.ROUTE_API_INDEX}/${routeId}`);

        return result.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};

const getIntersections = async () => {
    try {
        const response = await axios.get(api_paths.INTERSECTION_API_INDEX);

        return response.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};

const doSearchPath = async (searchCoordinates) => {
    const response = await axios.get(api_paths.GRAPH_API_SEARCH_PATH, {params: searchCoordinates});

    return response.data;
};

export default {
    name: "AppIndexRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle,
        "google-map-polyline": Polyline,
        "google-map-marker": Marker,
        "route-select-dialog": RouteSelectDialog,
        "toggle-button": ToggleButton,
        "address-display": AddressDisplay
    },
    data() {
        return {
            app_logo: APP_LOGO,
            currentRoute: null,
            routePath: [],
            routes: [],
            showSelectRouteDialog: false,
            debugIntersections: [],
            clickedCoordinatesStack: []
        };
    },
    computed: {
        searchFromCoordinate() {
            return this.clickedCoordinatesStack[0] || {};
        },
        searchToCoordinate() {
            return this.clickedCoordinatesStack[1] || {};
        }
    },
    async mounted() {
        const routes = await getRoutes();

        this.routes = routes || [];
    },
    methods: {
        routeSelect() {
            this.showSelectRouteDialog = true;
        },
        closeSelectRouteDialog() {
            this.showSelectRouteDialog = false;
        },
        async routeSelected(route) {
            this.currentRoute = route;

            const routeDetails = await getRoute(route.id);
            if (routeDetails) {
                const snapToRoadPoints = await snapToRoads(routeDetails.intersections);

                this.routePath = snapToRoadPoints;
            } else {
                this.routePath = [];
            }
            
            this.closeSelectRouteDialog();
        },
        async debugOnShowIntersections() {
            if (this.debugShowIntersections) {
                this.debugIntersections = [];
                this.debugShowIntersections = false;
            } else {
                const result = await getIntersections();
                if (!result.success) {
                    alert("Could not fetch intersections at this time."); // TODO: use something beautiful
                    return false;
                }
        
                this.debugIntersections = result.intersections;
                this.debugShowIntersections = true;
            }
        },
        mapClick({latLng}) {
            const coordinate = { lat: latLng.lat(), lng: latLng.lng() };
            const stackLimit = 2;
            this.clickedCoordinatesStack.push(coordinate);

            if (this.clickedCoordinatesStack.length > stackLimit) {
                this.clickedCoordinatesStack = this.clickedCoordinatesStack.splice(1);
            }
        },
        async searchPath() {
            const params = {
                from: this.searchFromCoordinate,
                to: this.searchToCoordinate
            };
            const response = await doSearchPath(params);

            if (response.exist) {
                const snapToRoadPoints = await snapToRoads(response.path);

                this.routePath = snapToRoadPoints;
            }
        },
        isObjectEmpty(value) {
            return isEmpty(value);
        }
    }
}
</script>
