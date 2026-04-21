import path from "node:path"
import process from "node:process"
import { fileURLToPath, URL } from "node:url"
import tailwindcss from "@tailwindcss/vite"
import vue from "@vitejs/plugin-vue"
import vueJsx from "@vitejs/plugin-vue-jsx"
import Components from "unplugin-vue-components/vite"
import { defineConfig, loadEnv } from "vite"
import { createSvgIconsPlugin } from 'vite-plugin-svg-icons'
import VueDevTools from "vite-plugin-vue-devtools"
import svgLoader from "vite-svg-loader"

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
	// Load env file based on `mode` in the current working directory.
	// Set the third parameter to '' to load all env regardless of the `VITE_` prefix.
	process.env = { ...process.env, ...loadEnv(mode, process.cwd(), "") }
	const baseApi = process.env.VITE_APP_BASE_API || '/dev-api'
	return {
		server: {
			port: 5183,
			host: true,
			open: true,
			proxy: {
				// 代理 /api 到后端（PCDS FastAPI）
				'/api': {
					target: process.env.VITE_APP_BASE_URL,
					changeOrigin: true,
				},
				// 兼容旧路径
				[baseApi]: {
					target: process.env.VITE_APP_BASE_URL,
					changeOrigin: true,
					rewrite: (p) => p.replace(new RegExp(`^${baseApi}`), '')
				},
			}
		},
		plugins: [
			tailwindcss(),
			vue({
				script: {
					defineModel: true
				}
			}),
			vueJsx(),
			createSvgIconsPlugin({
				// 指定需要缓存的图标文件夹
				iconDirs: [path.resolve(process.cwd(), 'src/assets/icons/svg')],
				// 指定 symbolId 格式
				symbolId: 'icon-[dir]-[name]'
			}),
			VueDevTools({
				launchEditor: process.env.VITE_LAUNCH_EDITOR || 'code'
			}),
			svgLoader(),
			Components({
				/** add here paths for auto-import */
				// dirs: ["src/components/cards"],
				dts: "src/unplugin.components.d.ts"
			})
		],
		resolve: {
			alias: {
				"@": fileURLToPath(new URL("./src", import.meta.url)),
				"node:process": "process/browser"
			}
		},
		optimizeDeps: {
			include: ["fast-deep-equal"]
		},
		define: {
			__APP_ENV__: JSON.stringify(process.env.APP_ENV)
		},
		css: {
			preprocessorOptions: {
				scss: {
					silenceDeprecations: ["legacy-js-api", "import"],
					api: "modern-compiler"
				}
			}
		}
	}
})
