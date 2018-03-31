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
        },
        strokeColor: {
            type: String,
            default: "#FF0000"
        }
    },

    watch: {
        path: 'createPolyline',
        visible: 'toggleVisibility'
    },

    created() {
        this._mapParent = null;
        let directParent = this.$parent;

        // move up the component tree until we found the google-map component
        while(directParent && !this._mapParent) {
            if (directParent["_mapInstance"]) {
                this._mapParent = directParent;
            } else {
                directParent = directParent.$parent;
            }
        }

        if (!this._mapParent) {
            throw new Error("Polyline map parent not found.");
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
                strokeColor: this.strokeColor,
                strokeOpacity: this.visible ? 0.5 : 0,
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