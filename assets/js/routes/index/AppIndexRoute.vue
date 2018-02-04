<template>
  <div class="app-index-route">
    <div class="map-container">
      <google-map>
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

export default {
    name: "AppIndexRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle,
        "google-map-polyline": Polyline,
        "route-select-dialog": RouteSelectDialog
    },
    data() {
        return {
            app_logo: APP_LOGO,
            currentRoute: null,
            routePath: [],
            routes: [],
            showSelectRouteDialog: false
        };
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
        }
    }
}
</script>
