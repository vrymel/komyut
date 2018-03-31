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

export default {
    name: "RoutePathDisplay",
    props: {
        route: {
            type: Object,
            default: () => {
            }
        },
        path: {
            type: Array,
            default: () => []
        }
    },
    data() {
        return {
            pathChunks: []
        };
    },
    watch: {
        path: 'chunkPath'
    },
    methods: {
        chunkPath: function() {
            const routeId = this.route.id;
            const chunkSize = 10;

            let chunks = chunk(this.path, chunkSize);

            this.pathChunks = chunks.map((c, index) => {
                return {
                    path: c,
                    key: routeId + "-" + index,
                    visible: false
                };
            });

            this.animatePath();
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

                currentIndex++;
                if (currentIndex >= pathChunksLength) {
                    currentIndex = 0;
                }
            }, 100);
        }
    }
}
</script>

