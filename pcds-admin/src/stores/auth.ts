import type { RouteRecordRaw } from "vue-router"
import { CacheEnum } from "@/types/enums.d"
import { clearAuthInfo, getToken } from "@/utils/auth"
import cache from "@/utils/cache"
import { authApi } from "@/views/Auth/api/auth.ts"
import { acceptHMRUpdate, defineStore } from "pinia"

// 适配 PCDS 后端的用户信息结构
export interface UserInfo {
	userId: number
	email: string
	nickname: string
	avatarUrl: string
	// 兼容管理台原有字段
	userName?: string
	nickName?: string
	avatar?: string
	admin?: boolean
	roles?: string[]
	permissions?: string[]
}

export const useAuthStore = defineStore("auth", {
	state: () => ({
		token: getToken() || null,
		userInfo: null as UserInfo | null,
		roles: [] as string[],
		permissions: [] as string[],
		routes: [] as RouteRecordRaw[]
	}),
	actions: {
		resetState() {
			this.token = null
			this.userInfo = null
			this.roles = []
			this.permissions = []
			this.routes = []
		},
		setAvatar(imgUrl: string) {
			if (this.userInfo != null) {
				this.userInfo.avatarUrl = imgUrl
			}
		},
		getAvatar() {
			const defAva = "/images/avatar-200.jpg"
			if (this.userInfo == null) return defAva
			return this.userInfo.avatarUrl || defAva
		},
		// 账号密码登录
		setLogged(payload: { email: string; password: string }) {
			return new Promise((resolve, reject) => {
				authApi
					.login(payload)
					.then((res: any) => {
						// PCDS 后端响应格式：{ code: 200, data: { token, user_id, email, nickname, avatar_url } }
						if (res.code === 200) {
							const data = res.data
							this.token = data.token
							cache.set(CacheEnum.TOKEN_KEY, data.token)
							resolve(true)
						} else {
							reject(res.msg || '登录失败')
						}
					})
					.catch((err: any) => reject(err))
			})
		},
		setLogout() {
			return new Promise((resolve, reject) => {
				authApi
					.logout()
					.then((data: any) => {
						clearAuthInfo()
						resolve(data)
					})
					.catch((error: any) => reject(error))
			})
		},
		updateUserInfo(payload: any) {
			return new Promise((resolve, reject) => {
				authApi
					.updateUserInfo(payload)
					.then((data: any) => resolve(data))
					.catch((error: any) => reject(error))
			})
		},
		updateUserPwd(payload: any) {
			return new Promise((resolve, reject) => {
				authApi
					.updatePassword(payload)
					.then((data: any) => resolve(data))
					.catch((error: any) => reject(error))
			})
		},
		queryUserInfo() {
			return new Promise((resolve, reject) => {
				authApi
					.getUserInfo()
					.then((res: any) => {
						// PCDS 后端响应格式：{ code: 200, data: { user_id, email, nickname, avatar_url } }
						if (res.code === 200) {
							const data = res.data
							this.userInfo = {
								userId: data.user_id,
								email: data.email,
								nickname: data.nickname,
								avatarUrl: data.avatar_url,
								// 兼容字段
								userName: data.email,
								nickName: data.nickname,
								avatar: data.avatar_url,
								admin: true,
								roles: ['admin'],
								permissions: ['*:*:*'],
							}
							this.roles = ['admin']
							this.permissions = ['*:*:*']
							resolve(this.userInfo)
						} else {
							reject(res)
						}
					})
					.catch((error: any) => reject(error))
			})
		}
	},
	getters: {
		isLogged(state) {
			return !!state.token
		},
		getUserInfo(state) {
			return state.userInfo
		},
		isRoleGranted(state) {
			return (roles?: string[]) => {
				if (!roles) return true
				if (roles.includes("all")) return true
				return roles.some(role => state.roles.includes(role))
			}
		}
	},
	persist: {
		omit: ["userInfo"]
	}
})

if (import.meta.hot) {
	import.meta.hot.accept(acceptHMRUpdate(useAuthStore, import.meta.hot))
}
