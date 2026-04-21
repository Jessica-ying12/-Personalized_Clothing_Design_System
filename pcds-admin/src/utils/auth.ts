import type { NavigationGuardNext, RouteLocationNormalized } from "vue-router"
import type { UserInfo } from "@/stores/auth"
import type { RouteMetaAuth } from "@/types/auth.d"
import router, { NOT_FOUND_ROUTE } from "@/router"
import { useAuthStore } from "@/stores/auth"
import { useRouterStore } from "@/stores/router"
import { CacheEnum } from "@/types/enums.d"
import cache from "@/utils/cache"
import { isHttp } from "@/utils/validate.ts"

export async function authCheck(route: RouteLocationNormalized, next: NavigationGuardNext) {
	const { auth, roles }: RouteMetaAuth = route.meta
	const authStore = useAuthStore()
	const routerStore = useRouterStore()

	// Logout handling
	if (route?.redirectedFrom?.name === "Logout") {
		await authStore.setLogout()
	}

	// Auth check: if not logged or role not granted
	const loginPath = `/login${window.location.search}`
	if (auth && (!authStore.isLogged || (roles && !authStore.isRoleGranted(roles)))) {
		// return next(loginPath)
		window.location.replace(loginPath)
		return
	}

	if (authStore.isLogged) {
		const userInfo: UserInfo | null = authStore.userInfo
		if (userInfo == null) {
			try {
				await authStore.queryUserInfo()
				const accessRoutes: any = await routerStore.generateRoutes()
				// 刷新路由
				accessRoutes.forEach((route: any) => {
					if (!isHttp(route.path)) {
						router.addRoute(route) // 动态添加可访问路由表
					}
				})
				router.addRoute(NOT_FOUND_ROUTE)
				return next({ ...route, replace: true })
			} catch (error: any) {
				const status = error?.response?.status ?? error?.code
				if (status === 401 || status === 403) {
					clearAuthInfo()
					window.location.replace(loginPath)
					return
				}
				// 非认证错误（如网络问题），仍然放行，避免白屏
				return next()
			}
		}

		// If checkAuth is true and user is logged in
		// if (checkAuth) {
		// 	return !roles || authStore.isRoleGranted(roles) ? authRedirect || "/" : route.path
		// }
	}
	return next()
}

export function getToken() {
	return cache.get(CacheEnum.TOKEN_KEY)
}

export function clearAuthInfo() {
	const authStore = useAuthStore()
	cache.remove(CacheEnum.TOKEN_KEY)
	authStore.resetState()
}