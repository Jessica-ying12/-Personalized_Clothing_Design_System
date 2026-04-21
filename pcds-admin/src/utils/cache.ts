import { CacheEnum } from "@/types/enums.d"

/**
 * 缓存工具对象，提供缓存的设置、获取、移除等操作。
 */
const cache = {
	key: CacheEnum.CACHE_KEY,
	/**
	 * 设置缓存数据。
	 * @param {string} key 缓存的键。
	 * @param {any} value 缓存的值。
	 * @param {string} [expire] 缓存的过期时间，单位为秒。
	 */
	set(key: string, value: any, expire?: string) {
		key = this.getKey(key)
		let data: any = {
			expire: expire ? this.time() + expire : "",
			value
		}
		if (typeof data === "object") {
			data = JSON.stringify(data)
		}
		try {
			window.localStorage.setItem(key, data)
			// eslint-disable-next-line unused-imports/no-unused-vars
		} catch (e) {
			return null
		}
	},
	/**
	 * 获取缓存数据。
	 * @param {string} key 缓存的键。
	 * @returns {any} 缓存的值，如果不存在或已过期则返回null。
	 */
	get(key: string): any {
		key = this.getKey(key)
		try {
			const data = window.localStorage.getItem(key)
			if (!data) {
				return null
			}
			const { value, expire } = JSON.parse(data)
			if (expire && expire < this.time()) {
				window.localStorage.removeItem(key)
				return null
			}
			return value
			// eslint-disable-next-line unused-imports/no-unused-vars
		} catch (e) {
			return null
		}
	},
	/**
	 * 获取当前时间戳（秒）。
	 * @returns {number} 当前时间戳。
	 */
	time(): number {
		return Math.round(new Date().getTime() / 1000)
	},
	/**
	 * 移除指定缓存。
	 * @param {string} key 缓存的键。
	 */
	remove(key: string): void {
		key = this.getKey(key)
		window.localStorage.removeItem(key)
	},
	/**
	 * 根据提供的键生成最终的缓存键。
	 * @param {string} key 原始键。
	 * @returns {string} 经过处理的缓存键。
	 */
	getKey(key: string): string {
		return this.key + key
	}
}

export default cache
