export default {
    mounted: function() {
        const initComponent = this.$options.initComponent;

        if (initComponent) {
            initComponent.call(this);
        }
    }
}