import type { Component } from "vue"
import process from "node:process"
import { isMobile as detectMobile } from "detect-touch-device"
import { h } from "vue"
import Icon from "@/components/common/Icon.vue"
import { format } from "date-fns"

export type OS = "Unknown" | "Windows" | "MacOS" | "UNIX" | "Linux"

// Transform File Instance in base64 string
export function file2Base64(blob: Blob): Promise<string> {
	return new Promise((resolve, reject) => {
		const reader = new FileReader()
		reader.readAsDataURL(blob)
		reader.onload = () => resolve(reader.result as string)
		reader.onerror = error => reject(error)
	})
}

export function isEnvDev() {
	return process.env.NODE_ENV === "development"
}
export function isEnvTest() {
	return process.env.NODE_ENV === "test"
}
export function isEnvProd() {
	return process.env.NODE_ENV === "production"
}

export function isMobile() {
	return detectMobile
}

export function renderIcon(icon: Component | string) {
	if (typeof icon === "string") {
		return () => h(Icon, { name: icon })
	} else {
		return () => h(Icon, null, { default: () => h(icon) })
	}
}

export function getOS(): OS {
	let os: OS = "Unknown"
	if (navigator.userAgent.includes("Win")) os = "Windows"
	if (navigator.userAgent.includes("Mac")) os = "MacOS"
	if (navigator.userAgent.includes("X11")) os = "UNIX"
	if (navigator.userAgent.includes("Linux")) os = "Linux"

	return os
}

export function delay(t: number) {
	return new Promise(res => setTimeout(res, t))
}

export function snakeToCamel(data: any): any {
	if (data === null) {
		return data
	}
	if (
		typeof data === "string" ||
		typeof data === "number" ||
		typeof data === "boolean" ||
		typeof data !== "object" ||
		data instanceof FormData
	) {
		return data
	}
	if (Array.isArray(data)) {
		return data.map(item => snakeToCamel(item))
	}
	const newData: any = {}
	Object.keys(data).forEach(key => {
		const newKey = key.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase())
		newData[newKey] = snakeToCamel(data[key])
	})
	return newData
}

export function camelToSnake(data: any): any {
	if (data === null) {
		return data
	}
	if (
		typeof data === "string" ||
		typeof data === "number" ||
		typeof data === "boolean" ||
		typeof data !== "object" ||
		data instanceof FormData
	) {
		return data
	}
	if (Array.isArray(data)) {
		return data.map(item => camelToSnake(item))
	}
	const newData: any = {}
	Object.keys(data).forEach(key => {
		const newKey = key.replace(/([a-z0-9])([A-Z])/g, "$1_$2").toLowerCase()
		newData[newKey] = camelToSnake(data[key])
	})
	return newData
}

/**
 * 构造树型结构数据
 * @param data 数据源
 * @param id id字段 默认 'id'
 * @param parentId 父节点字段 默认 'parentId'
 * @param children 孩子节点字段 默认 'children'
 */
export function handleTree<T extends Record<string, any>>(
	data: T[],
	idKey?: keyof T,
	parentKey?: keyof T,
	childrenKey?: keyof T
): T[] {
	const config = {
		id: idKey || "id",
		parentId: parentKey || "parentId",
		childrenList: childrenKey || "children"
	}

	const childrenListMap: { [key: string]: T[] } = {}
	const nodeIds: { [key: string]: T } = {}
	const tree: T[] = []

	for (const d of data) {
		const parentId = d[config.parentId] as string
		if (!childrenListMap[parentId]) {
			childrenListMap[parentId] = []
		}
		nodeIds[d[config.id] as string] = d
		childrenListMap[parentId].push(d)
	}

	for (const d of data) {
		const parentId = d[config.parentId] as string
		if (!nodeIds[parentId]) {
			tree.push(d)
		}
	}

	for (const t of tree) {
		adaptToChildrenList(t)
	}

	function adaptToChildrenList(o: T) {
		const id = o[config.id] as string
		if (childrenListMap[id]) {
			o[config.childrenList] = childrenListMap[id] as any
		}
		if (Array.isArray(o[config.childrenList])) {
			for (const c of o[config.childrenList] as T[]) {
				adaptToChildrenList(c)
			}
		}
	}

	return tree
}

export function base642File(base64: string, filename: string): Promise<Blob> {
	return new Promise((resolve, reject) => {
		try {
			const arr = base64.split(",")
			const mime = arr[0]?.match(/:(.*?);/)?.[1]
			const bstr = atob(arr[1])
			let n = bstr.length
			const u8arr = new Uint8Array(n)
			while (n--) u8arr[n] = bstr.charCodeAt(n)
			resolve(new File([u8arr], filename, { type: mime }))
		} catch (err) {
			reject(err)
		}
	})
}

export function formatDate(dateString: string): string {
	const date = new Date(dateString)
	return format(date, "yyyy-MM-dd HH:mm:ss")
}
