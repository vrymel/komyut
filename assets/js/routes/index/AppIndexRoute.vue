<template>
  <div class="app-index-route">
    <div class="map-container">
      <google-map />
    </div>

    <div 
    class="route-context">
      <div class="app-logo">
        <img alt="WaypointsDirect">
      </div>

      <div class="current city">
        <h6 class="header">City</h6>

        <div class="description">
          Cagayan de Oro City
        </div>
      </div>

      <div class="current route">
        <h6 class="header">Route</h6>

        <div class="description">
          {{ description }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Map from "../common/Map";
import Circle from "../common/Circle";

export default {
    name: "AppIndexRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle
    },
    data() {
        return {};
    },
    methods: {

    }
}
</script>
