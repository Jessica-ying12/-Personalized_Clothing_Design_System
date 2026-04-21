<template>
	<svg :class="svgClass" aria-hidden="true" :width="size" :height="size">
		<use :xlink:href="iconName" :fill="color" />
	</svg>
</template>

<script>
import { computed, defineComponent } from 'vue'

export default defineComponent({
  props: {
    iconClass: {
      type: String,
      required: true
    },
    className: {
      type: String,
      default: ''
    },
    color: {
      type: String,
      default: ''
    },
    size: {
      type: [String, Number],
      default: '1em'
    }
  },
  setup(props) {
    return {
      iconName: computed(() => `#icon-${props.iconClass}`),
      svgClass: computed(() => {
        if (props.className) {
          return `svg-icon ${props.className}`
        }
        return 'svg-icon'
      })
    }
  }
})
</script>

<style scoped lang="scss">
.sub-el-icon,
.nav-icon {
  display: inline-block;
  position: relative;
}

.svg-icon {
  position: relative;
  fill: currentColor;
  vertical-align: -2px;
}
</style>
