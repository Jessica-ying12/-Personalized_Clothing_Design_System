import { defineStore } from 'pinia'

export interface DictItem {
	key: string;
	value: any;
}

export interface State {
	dict: DictItem[];
}

export const useDictStore = defineStore('dict', {
	state: (): State => ({
		dict: new Array<DictItem>()
	}),
	actions: {
		// 获取字典
		getDict(_key: string | null): any {
			if (_key == null || _key === "") {
				return null
			}
			try {
				for (let i = 0; i < this.dict.length; i++) {
					if (this.dict[i].key === _key) {
						return this.dict[i].value
					}
				}
				// eslint-disable-next-line unused-imports/no-unused-vars
			} catch (e) {
				return null
			}
			return null // 添加默认返回值
		},
		// 设置字典
		setDict(_key: string, value: any): void {
			if (_key !== null && _key !== "") {
				this.dict.push({
					key: _key,
					value
				})
			}
		},
		// 删除字典
		removeDict(_key: string): boolean {
			let bln = false
			try {
				for (let i = 0; i < this.dict.length; i++) {
					if (this.dict[i].key === _key) {
						this.dict.splice(i, 1)
						return true
					}
				}
				// eslint-disable-next-line unused-imports/no-unused-vars
			} catch (e) {
				bln = false
			}
			return bln
		},
		// 清空字典
		cleanDict(): void {
			this.dict = new Array<DictItem>()
		},
		// 初始字典
		initDict(): void {
			// 初始化逻辑
		}
	}
})
