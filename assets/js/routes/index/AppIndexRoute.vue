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

        <div class="m-2 card route-select">
          <div class="card-body">
            <h6 class="card-title">Route</h6>

            <div 
              class="card-text"
              v-if="route">
              {{ route.description }}
            </div>
            <div
            class="card-text no-route-selected">No route selected</div>
          </div>
        </div>
      </div>
    </div>
</div></template>

<script>
import { APP_LOGO } from "../globals";

import Map from "../common/Map";
import Circle from "../common/Circle";

export default {
    name: "AppIndexRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle
    },
    data() {
        return {
            app_logo: APP_LOGO,
            route: null
        };
    },
    methods: {

    }
}
</script>
