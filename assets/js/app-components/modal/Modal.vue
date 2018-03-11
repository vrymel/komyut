<template>
  <div 
    class="modal fade" 
    ref="modal">
    <div class="modal-dialog">
      <div class="modal-content">
        <slot/>
      </div>
    </div>
  </div>
</template>

<script>
import {Modal} from "bootstrap/dist/js/bootstrap";

export default {
    name: "Modal",
    props: {
        visible: {
            type: Boolean,
            default: () => false
        },
    },
    watch: {
        visible: function() {
            this._modal.show();        
        },
    },
    mounted() {
        this._modal = new Modal(this.$refs.modal);
    },
}
</script>