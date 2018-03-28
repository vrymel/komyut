<script>
export default {
    name: "GoogleMapMarker",
    props: {
        position: {
            type: Object,
            required: true
        },
        label: {
            type: String,
            default: null
        }
    },

    watch: {
        position: function() {
            if (this._marker) {
                this._marker.setOptions({ position: this.position });
            }
        },
        label: function() {
            if (this._marker) {
                this._marker.setOptions({ label: this.label });
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

        const options = {
            position: this.position,
            map: map
        };
        if (this.label) {
            options.label = this.label;
        }

        this._marker = new google.maps.Marker(options);
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
