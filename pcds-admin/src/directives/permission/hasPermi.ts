/**
 * v-hasPermi 操作权限处理
 * Copyright (c) 2019 ruoyi
 */

import { useAuthStore } from "@/stores/auth"

export default {
  mounted: (el: HTMLElement, binding: any) => {
    const { value } = binding
    const authStore = useAuthStore()
    const permissions = authStore.permissions
    const all_permission = "*:*:*"

    let parsedValue: string[]

    if (typeof value === "string") {
      // 提取方括号内的内容
      const contentInsideBrackets = value.match(/\[(.*?)\]/)?.[1]
      if (contentInsideBrackets) {
        // 将提取的内容修正为合法的 JSON 格式
        const jsonFormattedContent = `[${contentInsideBrackets.replace(/'/g, '"')}]`
        try {
          // 使用 JSON.parse 安全地解析字符串为数组
          parsedValue = JSON.parse(jsonFormattedContent)
          // eslint-disable-next-line unused-imports/no-unused-vars
        } catch (error) {
          throw new Error("无法解析字符串为数组，请检查输入格式")
        }
      } else {
        throw new Error("未找到有效的数组格式")
      }
    } else if (Array.isArray(value)) {
      parsedValue = value
    } else {
      throw new TypeError("权限指令使用错误")
    }

    if (parsedValue.length > 0) {
      const hasPermission = permissions.some((key: string) => {
        return all_permission === key || parsedValue.includes(key)
      })

      if (!hasPermission) {
        el.parentNode && el.parentNode.removeChild(el)
      }
    }
  }
}
