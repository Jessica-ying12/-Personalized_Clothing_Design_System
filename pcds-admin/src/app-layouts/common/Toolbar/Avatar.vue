<template>
	<n-dropdown :options placement="bottom-end" @select="handleSelect">
		<n-avatar round :size="32" src="/images/avatar-64.jpg" :img-props="{ alt: 'avatar' }" />
	</n-dropdown>
</template>

<script lang="ts" setup>
import { NAvatar, NDropdown } from "naive-ui"
import { h, ref } from "vue"
import { useRouter } from "vue-router"
import { renderIcon } from "@/utils"

const UserIcon = "ion:person-outline"
const LogoutIcon = "ion:log-out-outline"
const DocsIcon = "ion:book-outline"
const router = useRouter()
const options = ref([
	{
		label: "个人中心",
		key: "route-Profile",
		icon: renderIcon(UserIcon)
	},
	{
		label: () =>
			h(
				"a",
				{
					href: "/",
					target: "_blank",
					rel: "noopenner noreferrer"
				},
				"文档中心"
			),
		key: "documentation",
		icon: renderIcon(DocsIcon)
	},
	{
		label: "退出登录",
		key: "route-Logout",
		icon: renderIcon(LogoutIcon)
	}
])
function handleSelect(key: string) {
	if (key.indexOf("route-") === 0) {
		const path = key.split("route-")[1]
		router.push({ name: path })
	}
}
</script>
