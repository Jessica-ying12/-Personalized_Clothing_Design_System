import CarbonIcons from "@/assets/icons/carbon.json"
import { addCollection, listIcons } from "@iconify/vue"
import { acceptHMRUpdate, defineStore } from "pinia"

export const useIconStore = defineStore("icon", {
	state: () => ({
		defaultIcons: [] as string[]
	}),
	actions: {
		init() {
			if (addCollection(CarbonIcons)) { /* empty */ }
			this.defaultIcons = listIcons("", "carbon")
		}
	},
	persist: {}
})

// 热更新
if (import.meta.hot) {
	import.meta.hot.accept(acceptHMRUpdate(useIconStore, import.meta.hot))
}
