<script>
export default {
    name: "GoogleMapMarker",
    props: {
        position: {
            type: Object,
            required: true
        }
    },

    watch: {
        position: function() {
            if (this._marker) {
                this._marker.setOptions({ position: this.position });
            }
        }
    },

    created() {
        if (this.$parent) {
            this._mapParent = this.$parent;
        }
    },

    async mounted() {
        const map = await this._mapParent.getMap();

        this._marker = new google.maps.Marker({
            position: this.position,
            map: map,
            title: 'Hello World!'
        });
    },

    beforeDestroy() {
        if (this._marker) {
            this._marker.setMap(null);
        }
    },

    render () {
        return ''
    }
};
</script>
