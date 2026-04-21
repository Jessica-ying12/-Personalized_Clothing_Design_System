import request from "@/utils/request"

export const menuApi = {
	getRouters: () => {
		// 后端无动态路由接口，返回空数组使用静态路由
		return Promise.resolve([])
	}
}
