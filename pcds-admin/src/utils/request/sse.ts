import { getToken } from "@/utils/auth"
import { fetchEventSource } from "@microsoft/fetch-event-source"

export interface StreamParams {
	content: string
}

export interface StreamCallbacks {
	onOpen?: () => void
	onMessage: (event: MessageEvent) => void
	onClose?: () => void
	onError?: (error: any) => void
}

// function paramsToString(params: any) {
// 	return new URLSearchParams(params).toString()
// }

// 定义回调函数的类型
type OnOpenCallback = () => void
type OnMessageCallback = (event: MessageEvent) => void
type OnCloseCallback = () => void
type OnErrorCallback = (error: any) => void

class SSEService {
	isConnected = false
	eventSource: any = null
	onOpen: OnOpenCallback | null = null
	onMessage: OnMessageCallback | null = null
	onClose: OnCloseCallback | null = null
	onError: OnErrorCallback | null = null

	constructor(
		onOpen: OnOpenCallback | null = null,
		onMessage: OnMessageCallback | null = null,
		onClose: OnCloseCallback | null = null,
		onError: OnErrorCallback | null = null
	) {
		this.onOpen = onOpen
		this.onMessage = onMessage
		this.onClose = onClose
		this.onError = onError
	}

	connect(url: string, params: any, options: any) {
		const defaultOptions = {
			openWhenHidden: true, // 页面隐藏保持连接
			headers: {
				"Content-Type": "application/json",
				Accept: "text/event-stream",
				Authorization: `Bearer ${getToken()}`
			}
			// retry: 3600
		}

		const fetchOptions = {
			method: "post",
			...defaultOptions,
			...options,
			body: JSON.stringify(params),
			onopen: this.onOpen,
			onmessage: this.onMessage,
			onclose: this.onClose,
			onerror: this.onError
		}
		this.eventSource = fetchEventSource(url, fetchOptions)
	}

	disconnect() {
		if (this.eventSource && this.isConnected) {
			this.eventSource.close()
			this.isConnected = false
		}
	}
}

export class ChatStreamService {
	private controller: AbortController | null = null
	private url: string
	private sseService: SSEService | null = null

	constructor(url: string) {
		this.url = url
	}

	startStream(params: StreamParams, callbacks: StreamCallbacks): AbortController | null {
		this.controller = new AbortController()
		this.sseService = new SSEService(callbacks.onOpen, callbacks.onMessage, callbacks.onClose, callbacks.onError)
		this.sseService.connect(this.url, params, {
			signal: this.controller.signal
		})
		return this.controller
	}

	stopStream(): void {
		this.controller?.abort()
		this.sseService?.disconnect()
		this.controller = null
		this.sseService = null
	}

	isConnected(): boolean {
		return this.controller !== null
	}
}

export default function sse(url: string) {
	return new ChatStreamService(url)
}
