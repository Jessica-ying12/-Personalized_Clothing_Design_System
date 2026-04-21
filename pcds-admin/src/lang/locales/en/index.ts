import chat from "./chat.json"
import common from "./common.json"
import _en from "./en.json"
import kb from "./kb.json"

const en = {
	...chat,
	...common,
	...kb,
	..._en
}

export default en
