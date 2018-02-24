<template>
  <div class="debug-controls m-2 card">
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
</template>

<script>
// to use this add the component
//  <debug-controls 
//    @debugIntersections="receiveDebugIntersections" />

// to show the intersections
// <google-map-circle 
//   v-for="(intersection) in debugIntersections"
//   :key="intersection.id"
//   :center="intersection"/> -->

import axios from "axios";
import api_paths from "../api_paths";

import ToggleButton from "../common/ToggleButton";

const getIntersections = async () => {
    try {
        const response = await axios.get(api_paths.INTERSECTION_API_INDEX);

        return response.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};

export default {
    name: "DebugControls",
    components: {
        "toggle-button": ToggleButton
    },
    data() {
        return {
            debugShowIntersections: false,
            debugIntersections: []
        };
    },
    methods: {
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

            this.$emit("debugIntersections", this.debugIntersections);
        },
    }
}
</script>
