<script>
export default {
    name: "GoogleMapCircle",
    props: {
        center: {
            type: Object,
            required: true
        }
    },

    created() {
        if (this.$parent) {
            this._mapParent = this.$parent;
        }
    },

    async mounted() {
        const map = await this._mapParent.getMap();

        this._circle = new google.maps.Circle({
            strokeColor: "#FF0000",
            strokeOpacity: 0.8,
            strokeWeight: 2,
            fillColor: "#FF0000",
            fillOpacity: 0.75,
            map: map,
            center: this.center,
            radius: 15
        });
    },

    beforeDestroy() {
        if (this._circle) {
            this._circle.setMap(null);
        }
    },

    render () {
        return ''
    }
};
</script>
