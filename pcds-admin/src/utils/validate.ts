/**
 * 判断value字符串是否为空
 * @param {string} value
 * @returns {Boolean}
 */
export function isEmpty(value: string | null | undefined): boolean {
	if (value == null || value === "" || value === undefined || value === "undefined") {
		return true
	}
	return false
}

/**
 * 判断url是否是http或https
 * @param {string} url
 * @returns {Boolean}
 */
export function isHttp(url: string): boolean {
	return url.includes('http://') || url.includes('https://')
}

/**
 * 判断path是否为外链
 * @param {string} path
 * @returns {Boolean}
 */
export function isExternal(path: string): boolean {
	return /^(?:https?:|mailto:|tel:)/.test(path)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validUsername(str: string): boolean {
	const validMap: string[] = ['admin', 'editor']
	return validMap.includes(str.trim())
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validLowerCase(str: string): boolean {
	const reg = /^[a-z]+$/
	return reg.test(str)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validUpperCase(str: string): boolean {
	const reg = /^[A-Z]+$/
	return reg.test(str)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function validAlphabets(str: string): boolean {
	const reg = /^[A-Z]+$/i
	return reg.test(str)
}

/**
 * @param {string} str
 * @returns {Boolean}
 */
export function isString(str: any): boolean {
	if (typeof str === 'string' || typeof str === 'string') {
		return true
	}
	return false
}

/**
 * @param {Array} arg
 * @returns {Boolean}
 */
export function isArray(arg: any): boolean {
	if (typeof Array.isArray === 'undefined') {
		return Object.prototype.toString.call(arg) === '[object Array]'
	}
	return Array.isArray(arg)
}
