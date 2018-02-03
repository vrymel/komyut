<template>
  <div class="route-select-dialog app-modal">
    <div class="modal-main">
      <header>
        Route Select
      </header>
      <div class="modal-body">
        <p>Select a route to view its path</p>

        <div class="list-group-container">
          <ul class="list-group">
            <li 
              class="list-group-item" 
              :class="{ active: activeRouteId == route.id }"
              v-for="(route, index) in routes"
              :key="index">
              <span class="description">{{ route.description }}</span>
            </li>
          </ul>
        </div>
      </div>
      <footer>
        <a 
          href="https://goo.gl/forms/FYTKd2Lt1EiZuiiH3" 
          target="_blank" 
          class="btn btn-info">Help us out!</a>
        &nbsp;
        <button 
          @click="close"
          type="button"
          class="btn btn-secondary">Close</button>
      </footer>
    </div>
  </div>
</template>

<script>
export default {
    name: "RouteSelectDialog",
    props: {
        routes: {
            type: Array,
            required: true
        }
    },
    data() {
        return {
            activeRouteId: null
        };
    },
    methods: {
        close() {
            this.$emit("close");
        }
    }
}
</script>
