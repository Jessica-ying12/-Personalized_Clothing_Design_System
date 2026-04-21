<template>
	<slot />
</template>

<script setup lang="ts">
import { useLoadingBar, useMessage, useNotification } from "naive-ui"
import { useGlobalActions } from "@/composables/useGlobalActions"

const message = useMessage()
const notification = useNotification()
const loadingBar = useLoadingBar()

useGlobalActions().init({ message, notification, loadingBar })
</script>
