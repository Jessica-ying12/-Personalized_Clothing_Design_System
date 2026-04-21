<template>
	<n-popover trigger="hover" :keep-alive-on-hover="true" style="background: black; color: white">
		<template #trigger>
			<Icon :size="16" :name="HelpIcon" style="cursor: pointer" :color="isDark ? 'white' : 'grey'" />
		</template>
		<span style="">{{ content }}</span>
	</n-popover>
</template>

<script setup lang="ts">
import { NPopover } from "naive-ui"
import { computed, toRefs } from "vue"
import { useThemeStore } from "@/stores/theme"

// const isLight = computed<boolean>(() => themeStore.isThemeLight)
const props = defineProps<{
	content: string
}>()
const themeStore = useThemeStore()
const isDark = computed<boolean>(() => themeStore.isThemeDark)
const { content } = toRefs(props)

const HelpIcon = "carbon:help-filled"
</script>
