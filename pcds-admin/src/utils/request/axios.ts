import type { RequestData, RequestOptions } from "@/types/request"
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from "axios"
import { RequestMethodsEnum } from "@/types/request-enums.d"
import axiosCancel from "@/utils/request/cancel"
import axios, {
	AxiosError

} from "axios"
import { cloneDeep, isFunction, merge } from "lodash"

export class Axios {
	private axiosInstance: AxiosInstance
	private readonly config: AxiosRequestConfig
	private readonly options: RequestOptions
	constructor(config: AxiosRequestConfig) {
		this.config = config
		this.options = config.requestOptions
		this.axiosInstance = axios.create(config)
		this.setupInterceptors()
	}

	/**
	 * @description 获取axios实例
	 */
	getAxiosInstance() {
		return this.axiosInstance
	}

	/**
	 * @description 设置拦截器
	 */
	setupInterceptors() {
		if (!this.config.axiosHooks) {
			return
		}
		const {
			requestInterceptorsHook,
			requestInterceptorsCatchHook,
			responseInterceptorsHook,
			responseInterceptorsCatchHook
		} = this.config.axiosHooks
		this.axiosInstance.interceptors.request.use(
			(config: any) => {
				this.addCancelToken(config)
				if (isFunction(requestInterceptorsHook)) {
					config = requestInterceptorsHook(config) as InternalAxiosRequestConfig<any>
				}
				return config
			},
			(err: Error) => {
				if (isFunction(requestInterceptorsCatchHook)) {
					requestInterceptorsCatchHook(err)
				}
				return err
			}
		)
		this.axiosInstance.interceptors.response.use(
			(response: AxiosResponse<RequestData>) => {
				this.removeCancelToken(response.config.method!, response.config.url!)
				if (isFunction(responseInterceptorsHook)) {
					response = responseInterceptorsHook(response)
				}
				return response
			},
			async (err: AxiosError) => {
				if (isFunction(responseInterceptorsCatchHook)) {
					responseInterceptorsCatchHook(err)
				}
				if (err.config?.method && err.config?.url && err.code !== AxiosError.ERR_CANCELED) {
					this.removeCancelToken(err.config.method, err.config.url)
				}
				if (err.code === AxiosError.ECONNABORTED || err.code === AxiosError.ERR_NETWORK) {
					return new Promise(resolve => setTimeout(resolve, 500)).then(() => this.retryRequest(err))
				}
				return Promise.reject(err)
			}
		)
	}

	/**
	 * @description 添加CancelToken
	 */
	addCancelToken(config: AxiosRequestConfig) {
		const { ignoreCancelToken } = config.requestOptions
		!ignoreCancelToken && axiosCancel.add(config)
	}

	/**
	 * @description 移除CancelToken
	 */
	removeCancelToken(method: string, url: string) {
		axiosCancel.remove(`${method}@${url}`)
	}

	/**
	 * @description 在请求失败时尝试重新发送请求。
	 * @param error AxiosError - 上次请求失败时的错误对象。
	 * @returns Promise - 如果不应该重试请求，则返回被拒绝的Promise；否则，返回新的请求Promise。
	 * @summary 该函数检查是否应该重试请求，并在符合条件的情况下递增重试计数并重新发送请求。
	 */
	/**
	 * @description 重新请求
	 */
	retryRequest(error: AxiosError) {
		// 获取错误配置信息
		const config: AxiosRequestConfig | undefined = error.config
		if (!config) {
			return Promise.reject(error)
		}
		const { retryCount, isOpenRetry } = config.requestOptions

		// 如果重试功能未开启或请求方法为POST，则直接拒绝请求
		if (!isOpenRetry || config.method?.toUpperCase() === RequestMethodsEnum.POST) {
			return Promise.reject(error)
		}

		// 初始化或递增重试计数
		config.retryCount = config.retryCount ?? 0
		// 如果重试次数超过预设的最大重试次数，则拒绝请求
		if (config.retryCount >= retryCount) {
			return Promise.reject(error)
		}
		// 重试计数递增
		config.retryCount++

		// 发送新的请求
		return this.axiosInstance.request(config)
	}

	/**
	 * @description get请求
	 */
	get<T = any>(config: Partial<AxiosRequestConfig>, options?: Partial<RequestOptions>): Promise<T> {
		return this.request({ ...config, method: RequestMethodsEnum.GET }, options)
	}

	/**
	 * @description post请求
	 */
	post<T = any>(config: Partial<AxiosRequestConfig>, options?: Partial<RequestOptions>): Promise<T> {
		return this.request({ ...config, method: RequestMethodsEnum.POST }, options)
	}

	/**
	 * @description delete请求
	 */
	delete<T = any>(config: Partial<AxiosRequestConfig>, options?: Partial<RequestOptions>): Promise<T> {
		return this.request({ ...config, method: RequestMethodsEnum.DELETE }, options)
	}

	/**
	 * @description put请求
	 */
	put<T = any>(config: Partial<AxiosRequestConfig>, options?: Partial<RequestOptions>): Promise<T> {
		return this.request({ ...config, method: RequestMethodsEnum.PUT }, options)
	}

	/**
	 * 发起网络请求的通用函数。
	 *
	 * 本函数封装了Axios的请求调用，提供了配置合并及请求前缀处理等功能，旨在简化请求的发起过程。
	 *
	 * @param config Axios请求配置的局部对象。可通过此参数定制化请求的各个细节。
	 * @param options 额外的请求选项，用于进一步定制化请求。此参数为可选参数。
	 * @returns 返回一个Promise对象，该对象在请求成功时解析为响应数据，在请求失败时拒绝。
	 */
	request<T = any>(config: Partial<AxiosRequestConfig>, options?: Partial<RequestOptions>): Promise<any> {
		// 合并传入的配置选项和默认选项，以确保请求配置的完整性。
		const opt: RequestOptions = merge({}, this.options, options)
		// 构建Axios请求配置，其中包括传入的配置、请求选项以及请求前缀等信息。
		const axioxConfig: AxiosRequestConfig = {
			...cloneDeep(config),
			requestOptions: opt
		}
		// 解构出请求选项中的URL前缀。
		const { urlPrefix } = opt
		// 如果存在URL前缀，则将其与请求URL合并，形成完整的请求路径。
		// 拼接请求前缀如api
		if (urlPrefix) {
			axioxConfig.url = `${urlPrefix}${config.url}`
		}
		// 返回一个Promise对象，该对象封装了Axios的请求过程。
		// 在请求成功时，Promise将解析为响应数据；在请求失败时，Promise将拒绝，并附带错误信息。
		return new Promise((resolve, reject) => {
			this.axiosInstance
				.request<any, AxiosResponse<RequestData<T>>>(axioxConfig)
				.then(res => {
					resolve(res)
				})
				.catch(err => {
					reject(err)
				})
		})
	}
}
