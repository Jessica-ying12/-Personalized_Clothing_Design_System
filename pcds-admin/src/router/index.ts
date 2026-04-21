import type { RouteRecordRaw } from "vue-router"
import { createRouter, createWebHistory } from "vue-router"
import { Layout } from "@/types/theme.d"
import { authCheck } from "@/utils/auth"
import Index from "@/views/index.vue"

export const constantRoutes = [
	{
		path: "/",
		name: "Index",
		component: Index,
		meta: { title: "首页", auth: true, roles: "all" }
	},
	{
		path: "/user-profile",
		name: "Profile",
		component: () => import("@/views/system/user/profile/index.vue"),
		meta: { title: "个人中心", auth: true, roles: "all" }
	},
	{
		path: "/login",
		name: "Login",
		component: () => import("@/views/Auth/Login.vue"),
		meta: {
			title: "登录",
			theme: { layout: Layout.Blank, boxed: { enabled: false }, padded: { enabled: false } },
			checkAuth: true,
			skipPin: true
		}
	},
	{
		path: "/logout",
		name: "Logout",
		redirect: "/login"
	},
	// PCDS 业务路由
	{
		path: "/pcds/users",
		name: "PcdsUsers",
		component: () => import("@/views/pcds/user/index.vue"),
		meta: { title: "用户管理", auth: true, roles: "all" }
	},
	{
		path: "/pcds/flat-designs",
		name: "PcdsFlatDesigns",
		component: () => import("@/views/pcds/flat-design/index.vue"),
		meta: { title: "平面图管理", auth: true, roles: "all" }
	},
	{
		path: "/pcds/3d-designs",
		name: "Pcds3dDesigns",
		component: () => import("@/views/pcds/design-3d/index.vue"),
		meta: { title: "立体图管理", auth: true, roles: "all" }
	},
	{
		path: "/pcds/design-options",
		name: "PcdsDesignOptions",
		component: () => import("@/views/pcds/design-options/index.vue"),
		meta: { title: "设计选项管理", auth: true, roles: "all" }
	},
]

export const NOT_FOUND_ROUTE: RouteRecordRaw = {
	path: "/:pathMatch(.*)*",
	name: "NotFound",
	component: () => import("@/views/NotFound.vue"),
	meta: {
		theme: { layout: Layout.Blank, boxed: { enabled: false }, padded: { enabled: false } },
		skipPin: true
	}
}

const router = createRouter({
	history: createWebHistory(import.meta.env.BASE_URL),
	routes: constantRoutes,
	scrollBehavior(to, from, savedPosition) {
		if (savedPosition) return savedPosition
		return { top: 0 }
	}
})

router.beforeEach(async (to, from, next) => {
	await authCheck(to, next)
})

export default router
