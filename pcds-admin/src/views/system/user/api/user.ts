import request from "@/utils/request"

export const userApi = {
	listUser: (data: Record<string, any>) => {
		return request.get({ url: "/system/user/list", params: data }, { isTransformResponse: false })
	},
	getUser: (userId: number | string) => {
		return request.get({ url: `/system/user/${userId}` }, { isTransformResponse: false })
	},
	addUser: (data: Record<string, any>) => {
		return request.post({ url: "/system/user", data })
	},
	updateUser: (data: Record<string, any>) => {
		return request.put({ url: "/system/user", data })
	},
	delUser: (userIds: string) => {
		return request.delete({ url: `/system/user/${userIds}` })
	},
	resetUserPwd: (userId: number, password: string) => {
		const data = {
			userId,
			password
		}
		return request.put({ url: "/system/user/resetPwd", data })
	},
	changeUserStatus: (userId: number, status: string) => {
		const data = { userId, status }
		return request.put({ url: "/system/user/changeStatus", data })
	},
	uploadAvatar: (data: Record<string, any>) => {
		return request.post(
			{
				url: "/system/user/profile/avatar",
				data,
				headers: {
					"Content-Type": "application/x-www-form-urlencoded"
				}
			},
			{ isTransformResponse: false }
		)
	},
	getAuthRole: (userId: number) => {
		return request.get({ url: `/system/user/authRole/${userId}` }, { isTransformResponse: false })
	},
	updateAuthRole: (data: Record<string, any>) => {
		return request.put({ url: "/system/user/authRole", params: data })
	},
	deptTreeSelect() {
		return request.get({ url: "/system/user/deptTree" })
	},
	export: (query: Record<string, any>) => {
		return request.post(
			{
				url: "/system/user/export",
				params: query,
				responseType: "blob"
			},
			{ isTransformResponse: false }
		)
	}
}
