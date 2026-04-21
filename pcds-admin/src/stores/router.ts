import type { RouteRecordRaw } from "vue-router"
import { acceptHMRUpdate, defineStore } from "pinia"
import {

	RouterView
} from "vue-router"

import { constantRoutes } from "@/router"
import { menuApi } from "@/views/Auth/api/menu.ts"

// 匹配views里面所有的.vue文件
const modules = import.meta.glob('../views/**/*.vue')

export const useRouterStore = defineStore("permission", {
	state: () => ({
		routes: [] as any [],
		addRoutes: [],
		routesList: [] as any [],
		menusList: [] as any [],
		routesKeepAliveList: [] as any []
	}),
	actions: {
		resetState() {
			this.routes = []
			this.addRoutes = []
			this.routesList = []
			this.menusList = []
			this.routesKeepAliveList = []
		},
		filterAsyncRouter(data: Array<any>, prevRoute?: RouteRecordRaw) {
			data?.forEach((menu: any, index: number) => {
				if (prevRoute) {
					menu.name = prevRoute ? `${String(prevRoute.name)}/${menu.name}` : menu.name
					menu.path = prevRoute ? `${prevRoute.path}/${menu.path}` : menu.path
					if (index === 0) {
						prevRoute.redirect = menu.path
						this.routesList.push(prevRoute)
					}
				}
				if (menu.component === "Layout" && !prevRoute) {
					menu.component = RouterView
					this.menusList.push(menu)
				} else if (menu.component === "ParentView" && !prevRoute) {
					menu.component = RouterView
				} else if (menu.component === "InnerLink" && !prevRoute) {
					menu.component = RouterView
					this.menusList.push(menu)
				} else {
					menu.component = loadView(menu.component)
					this.routesList.push(menu)
					if (menu.meta?.noCache) {
						this.routesKeepAliveList?.push(menu.name)
					}
				}
				if (menu.children?.length > 0) {
					this.filterAsyncRouter(menu.children, menu)
				}
			})
		},
		generateRoutes() {
			this.resetState()
			return new Promise((resolve, reject) => {
				menuApi
					.getRouters()
					.then(res => {
						const sdata = JSON.parse(JSON.stringify(res))
						// const rdata = JSON.parse(JSON.stringify(res))
						this.filterAsyncRouter(sdata)
						this.routes = this.routesList.concat(constantRoutes)
						resolve(this.routes)
					})
					.catch(error => {
						reject(error)
					})
			})
		}
	},
	getters: {

	}
})

export function loadView(view: string): (() => Promise<any>) | undefined {
	let res: (() => Promise<any>) | undefined
	for (const path in modules) {
		const dir = path.split('views/')[1].split('.vue')[0]
		if (dir === view) {
			res = () => modules[path]()
		}
	}
	return res
}

if (import.meta.hot) {
	import.meta.hot.accept(acceptHMRUpdate(useRouterStore, import.meta.hot))
}
