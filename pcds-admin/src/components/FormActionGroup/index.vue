<template>
	<n-space>
		<n-button v-if="showAdd" v-hasPermi="addPerms" type="primary" size="small" @click="handleAdd">
			<template #icon>
				<Icon :size="16" :name="AddIcon"></Icon>
			</template>
			{{ $t("btn_add") }}
		</n-button>

		<n-button
			v-if="showUpdate"
			v-hasPermi="updatePerms"
			type="info"
			size="small"
			:disabled="single"
			@click="handleUpdate()"
		>
			<template #icon>
				<Icon :size="14" :name="EditIcon"></Icon>
			</template>
			{{ $t("btn_edit") }}
		</n-button>

		<n-button v-if="showExport" v-hasPermi="exportPerms" type="warning" size="small" @click="handleExport()">
			<template #icon>
				<Icon :size="14" :name="ExportIcon"></Icon>
			</template>
			{{ $t("btn_export") }}
		</n-button>

		<n-button
			v-if="showDelete"
			v-hasPermi="deletePerms"
			type="error"
			size="small"
			:disabled="multiple"
			@click="handleDelete()"
		>
			<template #icon>
				<n-icon>
					<Icon :size="14" :name="DeleteIcon"></Icon>
				</n-icon>
			</template>
			{{ $t("btn_delete") }}
		</n-button>

		<n-button v-if="showExpand" type="primary" size="small" ghost @click="handleUnfoldOrFold">
			{{ $t("btn_unfold_or_fold") }}
		</n-button>

		<!-- 其余按钮插槽 -->
		<slot name="user-defined"></slot>
	</n-space>
</template>

<script setup lang="ts">
import { NButton, NIcon, NSpace } from "naive-ui"
import { ref, watch } from "vue"
import Icon from "@/components/common/Icon.vue"

const props = defineProps({
	showExpand: {
		type: Boolean,
		default: () => false
	},
	showAdd: {
		type: Boolean,
		default: () => true
	},
	addPerms: {
		type: Array,
		default: () => []
	},
	showUpdate: {
		type: Boolean,
		default: () => true
	},
	updatePerms: {
		type: Array,
		default: () => []
	},
	showDelete: {
		type: Boolean,
		default: () => true
	},
	deletePerms: {
		type: Array,
		default: () => []
	},
	showExport: {
		type: Boolean,
		default: () => true
	},
	exportPerms: {
		type: Array,
		default: () => []
	},
	selectRows: {
		type: Array,
		default: () => {
			return []
		}
	}
})
const emit = defineEmits(["add", "update", "delete", "export", "expand"])
// ----------------------- 图片图标 ---------------------
const AddIcon = "carbon:add"
const EditIcon = "carbon:edit"
const ExportIcon = "carbon:export"
const DeleteIcon = "carbon:delete"

const single = ref(true)
const multiple = ref(true)

const showAdd = ref(props.showAdd)
const showUpdate = ref(props.showUpdate)
const showDelete = ref(props.showDelete)
const showExport = ref(props.showExport)
const showExpand = ref(props.showExpand)
const addPerms = ref(props.addPerms)
const updatePerms = ref(props.updatePerms)
const deletePerms = ref(props.deletePerms)
const exportPerms = ref(props.exportPerms)

watch(
	() => props.selectRows,
	() => {
		single.value = props.selectRows.length !== 1
		multiple.value = !props.selectRows.length
	}
)

function handleAdd() {
	emit("add")
}

function handleUpdate() {
	emit("update")
}

function handleDelete() {
	emit("delete")
}

function handleExport() {
	emit("export")
}

function handleUnfoldOrFold() {
	emit("expand")
}
</script>

<style scoped lang="scss"></style>
