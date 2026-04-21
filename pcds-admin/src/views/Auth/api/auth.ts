import request from "@/utils/request"

export const authApi = {
	// 账号密码登录（对接 PCDS 后端）
	login: (data: Record<string, any>) => {
		return request.post({ url: "/api/auth/login", data }, { withToken: false, isTransformResponse: false })
	},
	logout: () => {
		return request.post({ url: "/api/auth/logout" })
	},
	// 获取用户信息（对接 PCDS 后端）
	getUserInfo: () => {
		return request.get({ url: "/api/profile/me" }, { isTransformResponse: false })
	},
	// 更新用户信息
	updateUserInfo: (data: Record<string, any>) => {
		return request.put({ url: "/api/profile/update", data })
	},
	// 修改密码
	updatePassword: (data: Record<string, any>) => {
		return request.post({ url: "/api/auth/change-password", data })
	},
	// 发送OTP验证码
	sendOtp: (data: Record<string, any>) => {
		return request.post({ url: "/api/auth/send-otp", data }, { withToken: false })
	},
	// 验证OTP
	verifyOtp: (data: Record<string, any>) => {
		return request.post({ url: "/api/auth/verify-otp", data }, { withToken: false, isTransformResponse: false })
	},
	// 注册
	register: (data: Record<string, any>) => {
		return request.post({ url: "/api/auth/register", data }, { withToken: false, isTransformResponse: false })
	},
	// 图形验证码（后端未实现，直接返回禁用状态）
	captcha: () => {
		return Promise.resolve({ captchaEnabled: false, registerEnabled: false, img: '', uuid: '' })
	},
	// 极验验证码校验（后端未实现，直接放行）
	captchaCheck: (_data: Record<string, any>) => {
		return Promise.resolve(true)
	},
}
