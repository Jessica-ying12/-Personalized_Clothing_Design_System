import type { Plugin } from "vue"
import { createPinia } from "pinia"
import { createPersistedState } from "pinia-plugin-persistedstate"
import { createApp } from "vue"
import VueApexCharts from "vue3-apexcharts"
import App from "@/App.vue"
import copy from "@/directives/copy"
import hasPermi from "@/directives/permission/hasPermi"
import hasRole from "@/directives/permission/hasRole"
import i18n from "@/lang"
import router from "@/router"

import 'virtual:svg-icons-register'

import "@/assets/scss/index.scss"
import "./tailwind.css"

const meta = document.createElement("meta")
meta.name = "naive-ui-style"
document.head.appendChild(meta)

const pinia = createPinia()
pinia.use(
	createPersistedState({
		key: id => `__persisted__${id}`
	})
)

const app = createApp(App)
app.use(pinia)
app.use(i18n)
app.use(VueApexCharts as Plugin)
app.use(router)

app.directive("hasPermi", hasPermi)
app.directive("hasRole", hasRole)
app.directive("copy", copy)
app.mount("#app")
