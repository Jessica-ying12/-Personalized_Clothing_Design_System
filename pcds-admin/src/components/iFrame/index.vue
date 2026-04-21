<template>
	<iframe
		:src="url"
		frameborder="no"
		style="width: 100%; height: 100%"
		scrolling="auto" />
</template>

<script setup>
import { computed, onMounted, ref } from "vue"

const props = defineProps({
  src: {
    type: String,
    required: true
  }
})

const height = ref(document.documentElement.clientHeight - 94.5 + "px;")
const loading = ref(true)
const url = computed(() => props.src)

onMounted(() => {
  setTimeout(() => {
    loading.value = false;
  }, 300);
  window.onresize = function temp() {
    height.value = document.documentElement.clientHeight - 94.5 + "px;";
  };
})
</script>

<style scoped>
/* 你可以在这里添加一些样式 */
</style>
