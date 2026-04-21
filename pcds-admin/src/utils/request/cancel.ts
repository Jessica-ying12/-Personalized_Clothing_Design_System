import { type AxiosRequestConfig } from "axios"

const cancelerMap = new Map<string, any>()

/**
 * 用于管理axios请求取消的类。
 * 这个类维护了一个映射，将URL与取消函数关联起来，以便在需要时取消相应的请求。
 */
class AxiosCancel {
	/**
	 * 单例模式的实例。
	 * 用于全局管理请求的取消操作。
	 */
	private static instance?: AxiosCancel

	/**
	 * 获取AxiosCancel的单例实例。
	 * 如果尚未创建实例，则创建新的实例。
	 * @returns AxiosCancel的单例实例。
	 */
	static createInstance() {
		return this.instance ?? (this.instance = new AxiosCancel())
	}

	/**
	 * 添加一个请求到管理映射中，如果已存在则替换。
	 * @param config axios请求配置，其中应包含请求的URL。
	 */
	add(config: AxiosRequestConfig) {
		const reqKey = `${config.method!}@${config.url!}`
		this.remove(reqKey)
		const controller = new AbortController()
		config.signal = controller.signal
		cancelerMap.set(reqKey, controller)
	}

	/**
	 * 从管理映射中移除一个请求。
	 * 如果请求存在，则调用取消函数并删除映射。
	 * @param reqKey 要取消的请求Key。
	 */
	remove(reqKey: string) {
		if (cancelerMap.has(reqKey)) {
			const controller = cancelerMap.get(reqKey)
			controller && controller.abort()
			cancelerMap.delete(reqKey)
		}
	}
}

/**
 * 创建并返回AxiosCancel的单例实例，用于请求的取消管理。
 * @returns AxiosCancel的单例实例。
 */
const axiosCancel = AxiosCancel.createInstance()

export default axiosCancel
