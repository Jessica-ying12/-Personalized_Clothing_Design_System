import { useGlobalActions } from "@/composables/useGlobalActions.ts"
import { useClipboard } from "@vueuse/core"

/**
 * copy 复制操作
 * 指令用法：
 *  <div v-copy>这里是内容</div> 复制"这里是内容"
 *  <div v-copy={{color: '#fff', hoverColor: 'red'}}>这里是内容</div> hover颜色red,默认颜色#fff
 *  <div v-copy={{content: '这里是真实的复制内容'}}>这里是内容</div> 只复制"这里是真实地复制内容"
 */
export default {
	beforeMount: (el: any, binding: any) => {
		const { value } = binding
		el._copyContent = value?.content || el.textContent
		const { copy } = useClipboard({
			source: el,
			legacy: true
		})
		el._clickEvent = () => {
			copy(el._copyContent)
				.then(() => {
					useGlobalActions().msgSuccess("复制成功")
				})
				.catch(() => {

				})
		}
		el._mouseleaveEvent = () => {
			el.style.cursor = "default"
			el.style.color = value?.color || ""
		}
		el._mouseenterEvent = () => {
			el.style.cursor = "pointer"
			el.style.color = value?.hoverColor || "var(--primary-060-color)"
		}
		el.addEventListener("click", el._clickEvent)
		el.addEventListener("mouseenter", el._mouseenterEvent)
		el.addEventListener("mouseleave", el._mouseleaveEvent)
	},
	beforeUnmount: (el: any) => {
		el.removeEventListener("click", el._clickEvent)
		el.removeEventListener("mouseenter", el._mouseleaveEvent)
		el.removeEventListener("mouseleave", el._mouseleaveEvent)
	}
}
