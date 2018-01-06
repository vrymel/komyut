<script>
export default {
    name: "GoogleMapPolyline",
    props: {
        path: {
            type: Array,
            required: true
        }
    },

    watch: {
        path: 'createPolyline'
    },

    created() {
        if (this.$parent) {
            this._mapParent = this.$parent;
        }
    },

    async mounted() {
        this._map = await this._mapParent.getMap();

        this.createPolyline();
    },

    beforeDestroy() {
        if (this._circle) {
            this._circle.setMap(null);
        }
    },

    methods: {
        createPolyline: function() {
            if (this._polyline) {
                this._polyline.setMap(null);
            }

            this._polyline = new google.maps.Polyline({
                path: this.path,
                geodesic: true,
                strokeColor: '#FF0000',
                strokeOpacity: 1.0,
                strokeWeight: 2
            });

            if (this._map) {
                this._polyline.setMap(this._map);
            }
        }
    },

    render() {
        return '';
    },
};
</script>