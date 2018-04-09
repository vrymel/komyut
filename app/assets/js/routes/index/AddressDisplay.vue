<template>
  <div class="address-display">
    <div v-if="address">
      {{ address }}
    </div>
    <div v-else>
      <span class="no-selected">No location selected</span>
    </div>
  </div>
</template>

<script>
import { isEmpty } from "lodash";
import { reverseGeocode } from "../services";

const getCoordinateAddress = async (coordinate) => {
    if (!isEmpty(coordinate)) {
        const geocodeResponse = await reverseGeocode(coordinate.lat, coordinate.lng);
        if (geocodeResponse && geocodeResponse.length) {
            const firstAddress = geocodeResponse[0];

            return firstAddress.formatted_address;
        }

        return null;
    }

    return null;
};

export default {
    name: "AddressDisplay",
    props: {
        coordinates: {
            type: Object,
            required: true
        }
    },
    data() {
        return {
            address: null
        };
    },
    watch: {
        coordinates: async function() {
            const address = await getCoordinateAddress(this.coordinates);

            this.address = address;
        }
    }
}
</script>

<style lang="scss" scoped>
    .address-display {
        font-size: 0.9em;

        .no-selected {
            color: gray;
        }
    }
</style>
