<template>
	<n-popover :show-arrow="false" placement="bottom" content-class="w-72 p-0!">
		<template #trigger>
			<n-badge :show="hasUnread" dot :color="primaryColor">
				<Icon :name="BellIcon" :size="21" class="text-default" />
			</n-badge>
		</template>
		<template #header>
			<div class="font-semibold">Notifications</div>
		</template>
		<template #default>
			<NotificationsList :max-items="MAX_ITEMS" class="max-h-[50vh]">
				<template #last>
					<div v-if="list.length > MAX_ITEMS" class="flex justify-center p-4">
						<n-button text @click="showDrawer = true">View all</n-button>
					</div>
				</template>
			</NotificationsList>
		</template>
		<template #footer>
			<NotificationsToolbar />
		</template>
	</n-popover>

	<n-drawer v-model:show="showDrawer" :width="400" class="max-w-[90vw]" :trap-focus="false">
		<n-drawer-content title="Notifications" closable body-content-class="p-0!">
			<NotificationsList />
			<template #footer>
				<NotificationsToolbar />
			</template>
		</n-drawer-content>
	</n-drawer>
</template>

<script lang="ts" setup>
import type { Notification } from "@/composables/useNotifications"
import { NBadge, NButton, NDrawer, NDrawerContent, NPopover } from "naive-ui"
import { computed, onMounted, ref } from "vue"
import Icon from "@/components/common/Icon.vue"
import NotificationsList from "@/components/common/Notifications/List.vue"
import NotificationsToolbar from "@/components/common/Notifications/Toolbar.vue"
import { useNotifications } from "@/composables/useNotifications"
import { useThemeStore } from "@/stores/theme"

const MAX_ITEMS = 7
const BellIcon = "ph:bell"
const themeStore = useThemeStore()
const primaryColor = computed(() => themeStore.style["primary-color"])
const hasUnread = useNotifications().hasUnread
const showDrawer = ref(false)
const list = useNotifications().list

onMounted(() => {
	if (window.innerWidth > 700 && list?.value[0] && list?.value[0].id !== 9999) {
		setTimeout(() => {
			const newItem: Notification = {
				id: 9999,
				category: "news",
				type: "success",
				title: "Good news",
				description: "HI! Welcome to the new version of the template.",
				read: false,
				date: "Today",
				action: () => {
					window.open("/", "_blank")
				},
				actionTitle: "Go to Themeforest"
			}

			useNotifications().prepend(newItem, { autoNotify: true })
		}, 10000)
	}
})
</script>
