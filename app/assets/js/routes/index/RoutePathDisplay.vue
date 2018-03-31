<template>
  <div class="route-path-display">
    <google-map-polyline
      v-if="path.length"
      :name="'routePathMain'"
      :path="path"
      :stroke-color="'#888888'"/>

    <google-map-polyline 
      v-for="chunk in pathChunks"
      :key="chunk.key"
      :name="chunk.key"
      :path="chunk.path"
      :visible="chunk.visible" />
  </div>
</template>

<script>
import { chunk } from "lodash";

const chunkPath = (routeId, path) => {
    let chunkSize = 10;
    let chunks = chunk(path, chunkSize);

    return chunks.map((c, index) => {
        return {
            path: c,
            key: routeId + "-" + index,
            visible: false
        };
    });
};

export default {
    name: "RoutePathDisplay",
    props: {
        route: {
            type: Object,
            default: () => { 
                return null;
            }
        }
    },
    data() {
        return {
            path: [],
            pathChunks: []
        };
    },
    watch: {
        route: "updateRouteContext"
    },
    methods: {
        updateRouteContext: function() {
            if (this.route) {
                this.path = this.route.path;
                this.pathChunks = chunkPath(this.route.id, this.path);

                this.animatePath();
            } else {
                this.path = [];
                this.pathChunks = [];

                if (this.runningInterval) {
                    clearInterval(this.runningInterval);
                }
            }
        },
        animatePath: function() {
            if (this.runningInterval) {
                clearInterval(this.runningInterval);
            }

            const pathChunksLength = this.pathChunks.length;
            let currentIndex = 0;

            this.runningInterval = setInterval(() => {
                if (currentIndex == 0) {
                    this.pathChunks[pathChunksLength - 1]["visible"] = false;
                }

                this.pathChunks[currentIndex]["visible"] = true;

                // hide previous chunk
                if (currentIndex > 0) {
                    this.pathChunks[currentIndex - 1]["visible"] = false;
                }

                currentIndex = (currentIndex + 1) % pathChunksLength;
            }, 100);
        }
    }
}
</script>

