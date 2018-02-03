<script>
export default {
    name: "GoogleMapPolyline",
    props: {
        name: {
            type: String,
            default: ''
        },
        path: {
            type: Array,
            required: true
        },
        visible: {
            type: Boolean,
            default: true
        }
    },

    watch: {
        path: 'createPolyline',
        visible: 'toggleVisibility'
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
        if (this._polyline) {
            this._polyline.setMap(null);
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
                strokeOpacity: 0.5,
                strokeWeight: 5
            });

            if (this._map) {
                this._polyline.setMap(this._map);
            }
        },
        toggleVisibility: function(value) {
            if (!value) {
                this._polyline.setOptions({strokeOpacity: 0});
            } else {
                this._polyline.setOptions({strokeOpacity: 0.5});
            }
        }
    },

    render() {
        return '';
    },
};
</script>