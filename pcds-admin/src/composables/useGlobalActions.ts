import type { MessageOptions } from "naive-ui"
import type { LoadingBarApiInjection } from "naive-ui/es/loading-bar/src/LoadingBarProvider"
import type { MessageApiInjection, MessageReactive } from "naive-ui/es/message/src/MessageProvider"
import type { NotificationOptions } from "naive-ui/es/notification/src/NotificationEnvironment"
import type { NotificationApiInjection, NotificationReactive } from "naive-ui/es/notification/src/NotificationProvider"
import type { Writable } from "type-fest"

export type NotificationObject = Writable<NotificationOptions>

interface InitPayload {
	message: MessageApiInjection
	notification: NotificationApiInjection
	loadingBar: LoadingBarApiInjection
}

let message: MessageApiInjection | null = null
let notification: NotificationApiInjection | null = null
let loadingBar: LoadingBarApiInjection | null = null

export function useGlobalActions() {
	return {
		init: (payload: InitPayload): void => {
			message = payload.message
			notification = payload.notification
			loadingBar = payload.loadingBar
		},
		message: (content: string, options?: MessageOptions): MessageReactive | undefined => {
			return message?.create(content, options || { type: "info" })
		},
		msgError: (content: string, options?: MessageOptions): MessageReactive | undefined => {
			return message?.create(content, options || { type: "error" })
		},
		msgSuccess: (content: string, options?: MessageOptions): MessageReactive | undefined => {
			return message?.create(content, options || { type: "success" })
		},
		msgWarning: (content: string, options?: MessageOptions): MessageReactive | undefined => {
			return message?.create(content, options || { type: "warning" })
		},
		notification: (options: NotificationOptions): NotificationReactive | undefined => {
			return notification?.create(options)
		},
		loadingBar
	}
}
