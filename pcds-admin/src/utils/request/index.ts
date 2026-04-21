import type { AxiosHooks } from "@/types/request"
import type { AxiosRequestConfig } from "axios"
import { useGlobalActions } from "@/composables/useGlobalActions.ts"
import config from "@/config"
import router from "@/router"
import { PageEnum } from "@/types/enums.d"
import { ContentTypeEnum, RequestCodeEnum } from "@/types/request-enums.d"
import { camelToSnake, snakeToCamel } from "@/utils"
import { clearAuthInfo, getToken } from "@/utils/auth"
import { Axios } from "@/utils/request/axios"
import { AxiosError } from "axios"
import { merge } from "lodash"

/**
 * 定义axios的钩子函数，用于请求和响应的拦截处理。
 * 这些钩子函数可以添加额外的功能，如请求时启动加载条，响应时处理数据或错误。
 */
const axiosHooks: AxiosHooks = {
	/**
	 * 请求拦截器钩子。
	 * 在请求发送前执行，用于添加token、处理请求参数等。
	 * @param config axios请求配置
	 * @returns 返回修改后的请求配置
	 */
	requestInterceptorsHook(config) {
		useGlobalActions().loadingBar?.start()
		const { withToken, isCamelToSnakeCase } = config.requestOptions
		const headers = config.headers || {}
		// 添加token
		if (withToken) {
			// 让每个请求携带自定义token 请根据实际情况自行修改
			headers.Authorization = `Bearer ${getToken()}`
		}
		// body
		if (isCamelToSnakeCase && config.data) {
			config.data = camelToSnake(config.data || {})
		}
		// query
		if (isCamelToSnakeCase && config.params) {
			config.params = camelToSnake(config.params || {})
		}
		config.headers = headers
		return config
	},

	/**
	 * 请求错误拦截器钩子。
	 * 在请求错误发生时执行，用于处理错误并显示错误信息。
	 * @param err 错误对象
	 * @returns 返回错误对象
	 */
	requestInterceptorsCatchHook(err) {
		useGlobalActions().loadingBar?.error()
		return err
	},
	/**
	 * 响应拦截器钩子。
	 * 在请求响应返回后执行，用于处理响应数据、验证响应状态等。
	 * @param response axios响应对象
	 * @returns 返回处理后的响应数据或抛出错误
	 */
	async responseInterceptorsHook(response) {
		useGlobalActions().loadingBar?.finish()
		const { isTransformResponse, isReturnDefaultResponse, isSnakeToCamelCase } = response.config.requestOptions

		// 返回默认响应，当需要获取响应头及其他数据时可使用
		if (isReturnDefaultResponse) {
			return response
		}
		// 是否需要对数据进行处理
		if (!isTransformResponse) {
			return response.data
		}
		const { code, data, msg } = response.data

		switch (code) {
			case RequestCodeEnum.SUCCESS:
				if (isSnakeToCamelCase && data) {
					return snakeToCamel(data)
				} else {
					return data
				}

			case RequestCodeEnum.UNAUTHORIZE:
				msg && useGlobalActions().msgError(msg)
				clearAuthInfo()
				await router.push(PageEnum.LOGIN)
				return Promise.reject(new Error(msg || "Unauthorized access"))

			default:
				msg && useGlobalActions().msgError(msg)
				return Promise.reject(data)
		}
	},

	/**
	 * 响应错误拦截器钩子。
	 * 在请求响应错误发生时执行，用于处理错误并显示错误信息。
	 * @param error 错误对象
	 * @returns 返回拒绝的错误对象
	 */
	responseInterceptorsCatchHook(error) {
		useGlobalActions().loadingBar?.error()
		if (error.code !== AxiosError.ERR_CANCELED) {
			error.message && useGlobalActions().msgError(error.message)
		}
		return Promise.reject(error)
	}
}

const defaultOptions: AxiosRequestConfig = {
	timeout: config.timeout,
	headers: { "Content-Type": ContentTypeEnum.JSON, version: config.version },

	// 处理 axios的钩子函数
	axiosHooks,
	// 每个接口可以单独配置
	requestOptions: {
		// 是否需要将下划线形式字符串(snake_case)转换为小驼峰形式字符串(camelCase)
		isSnakeToCamelCase: false,
		// 是否需要将小驼峰形式字符串(camelCase)转换为下划线形式字符串(snake_case)
		isCamelToSnakeCase: false,
		// 是否返回默认的响应
		isReturnDefaultResponse: false,
		// 需要对返回数据进行处理
		isTransformResponse: true,
		// 接口拼接地址
		urlPrefix: config.urlPrefix,
		// 忽略取消请求
		ignoreCancelToken: false,
		// 是否携带token
		withToken: true,
		// 开启请求超时重新发起请求请求机制
		isOpenRetry: true,
		// 重新请求次数
		retryCount: 1
	}
}

function createAxios(opt?: Partial<AxiosRequestConfig>) {
	return new Axios(
		// 深度合并
		merge(defaultOptions, opt || {})
	)
}
const request = createAxios()
export default request
