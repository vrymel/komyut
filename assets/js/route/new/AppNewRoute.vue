<template>
    <div class="app-new-route">
        <div class="map">
            <google-map></google-map>
        </div>
        <div class="sidebar">Sidebar is here</div>
    </div>
</template>

<script>
import Map from "../common/Map.vue";

export default {
    name: "app-new-route",
    components: {
        'google-map': Map
    }
}
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

