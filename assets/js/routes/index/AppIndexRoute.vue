<template>
  <div class="app-index-route">
    <div class="map-container">
      <google-map />
    </div>

    <div 
    class="sidebar">
      <div class="current city">
        <h6 class="header">City</h6>

        <div class="description">
          Cagayan de Oro City
        </div>
      </div>

      <div class="current route">
        <h6 class="header">Route</h6>

        <div 
          class="description"
          v-if="route">
          {{ route.description }}
        </div>
        <div
        class="description no-route-selected">No route selected</div>
      </div>
    </div>
  </div>
</template>

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
