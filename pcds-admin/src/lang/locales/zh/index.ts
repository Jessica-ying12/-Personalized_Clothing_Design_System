import chat from "./chat.json"
import common from "./common.json"
import kb from "./kb.json"
import _zh from "./zh.json"

const zh = {
	...chat,
	...common,
	...kb,
	..._zh
}

export default zh
