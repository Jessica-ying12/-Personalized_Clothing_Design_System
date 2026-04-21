import type { AxiosRequestConfig, AxiosResponse } from "axios"

/**
 * 引入axios库，同时在axios的AxiosRequestConfig接口中添加新的可选属性。
 * 这些属性为retryCount、axiosHooks和requestOptions，用于扩展axios的功能。
 */
import "axios"
declare module "axios" {
	/**
	 * 扩展AxiosRequestConfig接口，添加自定义配置选项。
	 * 这些选项包括重试次数、axios钩子函数和请求选项对象。
	 */
	interface AxiosRequestConfig {
		retryCount?: number
		axiosHooks?: AxiosHooks
		requestOptions: RequestOptions
	}
}

/**
 * 定义请求选项接口，包含各种配置开关和参数。
 * 这些选项用于定制每个请求的行为，如是否将参数放在data中，是否返回默认响应等。
 */
export interface RequestOptions {
	// 是否返回默认的响应
	isReturnDefaultResponse: boolean
	// 是否需要对返回数据进行处理
	isTransformResponse: boolean
	// 是否需要将下划线形式字符串(snake_case)转换为小驼峰形式字符串(camelCase)
	isSnakeToCamelCase: boolean
	// 是否需要将小驼峰形式字符串(camelCase)转换为下划线形式字符串(snake_case)
	isCamelToSnakeCase: boolean
	// 接口拼接地址
	urlPrefix: string
	// 忽略取消请求
	ignoreCancelToken: boolean
	// 是否携带token
	withToken: boolean
	// 开启请求超时重新发起请求请求机制
	isOpenRetry: boolean
	// 重新请求次数
	retryCount: number
}

/**
 * 定义axios钩子函数接口，包含请求和响应拦截器的钩子函数。
 * 这些钩子函数可以在请求发送前或响应返回后进行自定义处理。
 */
export interface AxiosHooks {
	requestInterceptorsHook?: (config: AxiosRequestConfig) => AxiosRequestConfig
	requestInterceptorsCatchHook?: (error: Error) => void
	responseInterceptorsHook?: (response: AxiosResponse<RequestData<T>>) => AxiosResponse<RequestData> | RequestData | T
	responseInterceptorsCatchHook?: (error: AxiosError) => void
}

/**
 * 定义请求数据接口，包含标准的响应结构。
 * 每个响应都包含一个状态码、数据、消息和一个显示标志。
 */
export interface RequestData<T = any> {
	code: number
	data: T
	msg: string
}
