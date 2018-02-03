<template>
  <div class="app-index-route">
    <div class="map-container">
      <google-map />
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

import Map from "../common/Map";
import Circle from "../common/Circle";
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
        "route-select-dialog": RouteSelectDialog
    },
    data() {
        return {
            app_logo: APP_LOGO,
            currentRoute: null,
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
        routeSelected(route) {
            this.currentRoute = route;

            getRoute(route.id);
            
            this.closeSelectRouteDialog();
        }
    }
}
</script>
