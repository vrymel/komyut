<template>
  <button
  :class="stateClass"
  @click="onClick">
    <slot/>
  </button>
</template>

<script>
export default {
    name: "ToggleButton",

    props: {
        active: {
            type: Boolean,
            default: false  
        },
        value: {
            type: String,
            required: true
        },
        activeStateClass: {
            type: String,
            default: 'info'
        },
        inactiveStateClass: {
            type: String,
            default: 'secondary'
        }
    },

    computed: {
        stateClass() {
            return {
                btn: true,
                'btn-info': this.active,
                'btn-secondary': !this.active
            }
        }
    },

    methods: {
        onClick() {
            this.$emit("click", this.value);
        }
    }
}
</script>
