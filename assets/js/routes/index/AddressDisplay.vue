<template>
  <div class="address-display">
    {{ address }}
  </div>
</template>

<script>
import { reverseGeocode } from "../services";

const getCoordinateAddress = async (coordinate) => {
    if (coordinate) {
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
            address: "Not defined"
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

