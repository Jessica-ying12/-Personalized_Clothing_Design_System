import { useDictStore } from "@/stores/dict.ts"
import { dictApi } from "@/views/system/dict/api/dict.ts"
import { ref, toRefs } from "vue"

/**
 * 获取字典数据
 */
export function useDict(...args: string[]) {
	const res = ref<{ [key: string]: any[] }>({})
	return (() => {
		args.forEach((dictType) => {
			res.value[dictType] = []
			const dicts = useDictStore().getDict(dictType)
			if (dicts) {
				res.value[dictType] = dicts
			} else {
				dictApi.getDicts(dictType).then(resp => {
					res.value[dictType] = resp.map((p: any) => ({
						label: p.dictLabel,
						value: p.dictValue,
						elTagType: p.listClass,
						elTagClass: p.cssClass
					}))
					useDictStore().setDict(dictType, res.value[dictType])
				})
			}
		})
		return toRefs(res.value)
	})()
}