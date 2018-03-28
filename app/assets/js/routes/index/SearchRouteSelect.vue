<template>
  <div class="search-route-select">
    <div class="card-block my-2">
      <div class="card">
        <div class="card-body">
          <h6 class="card-title">From (A)</h6>
          <address-display :coordinates="fromAddress"/>
        </div>
      </div>
    </div>

    <div class="card-block my-2">
      <div class="card">
        <div class="card-body">
          <h6 class="card-title">To (B)</h6>
          <address-display :coordinates="toAddress"/>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import AddressDisplay from "./AddressDisplay";

export default {
    name: "SearchRouteSelect",
    components: {
        "address-display": AddressDisplay
    },
    props: {
        fromAddress: {
            type: Object,
            default: function () {}
        },
        toAddress: {
            type: Object,
            default: function() {}
        }
    }
}
</script>
