import type { MenuMixedOption } from "naive-ui/es/menu/src/interface"
import type { Component } from "vue"
import { h } from "vue"
import { RouterLink } from "vue-router"
import Icon from "@/components/common/Icon.vue"
import SvgIcon from "@/components/SvgIcon/index.vue"
import { useRouterStore } from "@/stores/router"
import { renderIcon } from "@/utils"

const HomeIcon = "carbon:home"

function renderSvgIcon(icon: Component | string) {
	if (!icon) return
	if (icon === "") return
	if (icon === "#") return
	if (typeof icon === "string") {
		if (icon.startsWith("carbon:")) {
			return () => h(Icon, { name: icon })
		}
		return () => h(SvgIcon, { iconClass: icon, className: 'nav-icon' })
	} else {
		return () => h(Icon, null, { default: () => h(icon) })
	}
}
function createMenus(route: any): MenuMixedOption | undefined {
	if (route.hidden) {
		return
	}
	const { title, icon, link } = route.meta
	const key = route.name
	if (link) {
		return {
			label: () =>
				h(
					'a', // 使用 'a' 标签代替 'RouterLink'
					{
						href: link, // 设置 href 属性
						target: '_blank', // 设置 target 为 _blank 以在新页面中打开
						rel: 'noopener noreferrer' // 添加 rel 属性以提高安全性
					},
					{ default: () => title }
				),
			key,
			icon: renderSvgIcon(icon)
		} as MenuMixedOption
	}
	if (route.children) {
		const children = route.children.filter((child: any) => !child.hidden).map((child: any) => createMenus(child))
		if (children.length) {
			return {
				label: title,
				key,
				icon: renderSvgIcon(icon),
				children
			} as MenuMixedOption
		}
		else {
			return {
				label: title,
				key,
				icon: renderSvgIcon(icon)
			} as MenuMixedOption
		}
	} else {
		return {
			label: () =>
				h(
					RouterLink,
					{
						to: {
							path: route.path
						}
					},
					{ default: () => title }
				),
			key,
			icon: renderSvgIcon(icon)
		} as MenuMixedOption
	}
}

// eslint-disable-next-line unused-imports/no-unused-vars
export default function getItems(args: { mode: "vertical" | "horizontal"; collapsed: boolean }): MenuMixedOption[] {
	const routerStore = useRouterStore()
	const menus: MenuMixedOption[] = []
	menus.push({
		label: () =>
			h(
				RouterLink,
				{
					to: {
						name: "Index"
					}
				},
				{ default: () => "首页" }
			),
		key: "Index",
		icon: renderIcon(HomeIcon)
	})
	const routes = routerStore.menusList
	routes.forEach(route => {
		const m = createMenus(route)
		if (m) menus.push(m)
	})
	return menus
}
