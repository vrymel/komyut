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
import $ from "jquery";
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
            if (this.visible) {
                this._modal.show();
            } else {
                this._modal.hide();
            }
        },
    },
    mounted() {
        // Modal triggers the event on the jQuery object so we need to use jQuery.on
        $(this.$refs.modal).on("hidden.bs.modal", () => {
            this.$emit("modal-hidden");
        });

        this._modal = new Modal(this.$refs.modal);
        if (this.visible) {
            this._modal.show();
        }
    },
}
</script>