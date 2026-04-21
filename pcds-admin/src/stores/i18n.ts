import type { NDateLocale, NLocale } from "naive-ui"
import type { WritableComputedRef } from "vue"
import type { ComposerTranslation } from "vue-i18n"
import type { LocaleCodes } from "@/lang/config"
import { dateEnUS, dateZhCN, enUS, zhCN } from "naive-ui"
import { acceptHMRUpdate, defineStore } from "pinia"
import { useI18n } from "vue-i18n"

export const useLocalesStore = defineStore("i18n", {
	state: () => {
		return {
			locale: useI18n().locale as WritableComputedRef<LocaleCodes, string>,
			availableLocales: useI18n().availableLocales as LocaleCodes[]
		}
	},
	actions: {
		setLocale(locale: LocaleCodes): LocaleCodes {
			this.locale = locale
			return locale
		}
	},
	getters: {
		t(): ComposerTranslation {
			return useI18n().t
		},
		naiveuiLocales(): { code: LocaleCodes; ui: NLocale; date: NDateLocale }[] {
			return [
				{ code: "en", ui: enUS, date: dateEnUS },
				{ code: "zh", ui: zhCN, date: dateZhCN }
			]
		},
		naiveuiLocale(state): NLocale | undefined {
			return this.naiveuiLocales.find(locale => locale.code === state.locale)?.ui
		},
		naiveuiDateLocale(state): NDateLocale | undefined {
			return this.naiveuiLocales.find(locale => locale.code === state.locale)?.date
		}
	},
	persist: {
		// @ts-expect-error "Type instantiation is excessively deep and possibly infinite" ts(2589)
		pick: ["locale"]
	}
})

if (import.meta.hot) {
	import.meta.hot.accept(acceptHMRUpdate(useLocalesStore, import.meta.hot))
}
