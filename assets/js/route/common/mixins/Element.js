export default {
    created: function() {
        if (this.$parent) {
            this.mapParent = this.$parent;
        }
    }
};