<template>
  <div class="app-index-route">
    <div class="map-container">
      <google-map>
        <google-map-circle 
          v-for="(intersection) in debugIntersections"
          :key="intersection.id"
          :center="intersection"
          @click="debugIntersectionClick" />

        <google-map-polyline 
          v-if="routePath.length"
          :name="'routePath'"
          :path="routePath" />
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
            <div>{{ searchStartIntersection }}</div>
          </div>

          <div class="card-block my-2">
            <div>{{ searchToIntersection }}</div>
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

import api_paths from "../api_paths";
import { APP_LOGO } from "../globals";
import { snapToRoads } from "../services";
import ToggleButton from "../common/ToggleButton";

import Map from "../common/Map";
import Circle from "../common/Circle";
import Polyline from "../common/Polyline";

import RouteSelectDialog from "./RouteSelectDialog";

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

const doSearchPath = async (params) => {
    const response = await axios.get(api_paths.GRAPH_API_SEARCH_PATH, {params});

    return response.data;
};

export default {
    name: "AppIndexRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle,
        "google-map-polyline": Polyline,
        "route-select-dialog": RouteSelectDialog,
        "toggle-button": ToggleButton,
    },
    data() {
        return {
            app_logo: APP_LOGO,
            currentRoute: null,
            routePath: [],
            routes: [],
            showSelectRouteDialog: false,
            debugIntersections: [],
            debugSelectIntersectionStack: [],
        };
    },
    computed: {
        searchStartIntersection() {
            // TODO: Replace this with actual an actual coordinate that the user
            // clicked on the page, right now, we just return the clicked
            // intersection. 
            // When we incorporate the nearest intersection calculation
            // in the app, that will be the time to replace this (searchStartIntersection, searchToIntersection)
            return this.debugSelectIntersectionStack[0];
        },
        searchToIntersection() {
            return this.debugSelectIntersectionStack[1];
        },
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
        debugIntersectionClick(googleData) {
            const stackLimit = 2;
            this.debugSelectIntersectionStack.push(googleData);

            if (this.debugSelectIntersectionStack.length > stackLimit) {
                this.debugSelectIntersectionStack = this.debugSelectIntersectionStack.splice(1);
            }
        },
        async searchPath() {
            const params = {
                from_intersection_id: this.searchStartIntersection.id,
                to_intersection_id: this.searchToIntersection.id
            };
            const response = await doSearchPath(params);

            if (response.exist) {
                const snapToRoadPoints = await snapToRoads(response.path);

                this.routePath = snapToRoadPoints;
            }
        }
    }
}
</script>
