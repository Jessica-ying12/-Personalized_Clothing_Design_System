<template>
	<n-card class="settings">
		<n-form ref="refForm" :label-width="80" :model="formValue" :rules="formRules">
			<div class="title">{{ $t("general") }}</div>
			<div class="flex flex-col justify-start md:flex-row md:gap-4">
				<n-form-item :label="$t('username')" path="userName" class="basis-1/2">
					<n-input :value="userInfo?.userName" readonly>
						<template #prefix>@</template>
					</n-input>
				</n-form-item>
				<n-form-item :label="$t('email')" path="email" class="basis-1/2">
					<n-input v-model:value="formValue.email" :placeholder="$t('please_input_email')" />
				</n-form-item>
			</div>
			<div class="title">{{ $t("profile_info") }}</div>
			<div class="flex flex-col justify-start md:flex-row md:gap-4">
				<n-form-item :label="$t('nickname')" path="nickName" class="basis-1/2">
					<n-input v-model:value="formValue.nickName" :placeholder="$t('please_input_nickname')"></n-input>
				</n-form-item>
				<n-form-item :label="$t('phone')" path="phonenumber" class="basis-1/2">
					<n-input v-model:value="formValue.phonenumber" :placeholder="$t('please_input_phone')" />
				</n-form-item>
			</div>
			<div class="flex flex-col justify-start md:flex-row md:gap-4">
				<n-form-item :label="$t('sex')" path="sex" class="basis-1/2">
					<n-radio-group v-model:value="formValue.sex" size="small" class="mt-2">
						<n-space>
							<n-radio value="0">{{ $t("male") }}</n-radio>
							<n-radio value="1">{{ $t("female") }}</n-radio>
						</n-space>
					</n-radio-group>
				</n-form-item>
			</div>
			<n-form-item>
				<n-button type="primary" @click="handleSubmit">{{ $t("save") }}</n-button>
			</n-form-item>
		</n-form>
	</n-card>
</template>

<script setup lang="ts">
import type { FormInst } from "naive-ui"
import { NButton, NCard, NForm, NFormItem, NInput, NRadio, NRadioGroup, NSpace } from "naive-ui"
import { computed, onMounted, ref, watch } from "vue"
import { useGlobalActions } from "@/composables/useGlobalActions.ts"
import { useAuthStore } from "@/stores/auth"

import { useLocalesStore } from "@/stores/i18n"

const localesStore = useLocalesStore()
const { t } = localesStore
const authStore = useAuthStore()
const userInfo = computed(() => authStore.userInfo)

// ----------------------- 表单操作：更新管理员信息  ---------------------
const refForm = ref<FormInst | null>(null)
const formValue = ref({
	phonenumber: "",
	email: "",
	nickName: "",
	sex: ""
})
const formRules = {
	phonenumber: {
		required: true,
		message: t("please_input_phone"),
		trigger: ["blur"]
	},
	email: {
		required: true,
		message: t("please_input_email"),
		trigger: ["blur"]
	},
	nickName: {
		required: true,
		message: t("please_input_nickname"),
		trigger: ["blur"]
	}
}

function handleSubmit() {
	refForm.value?.validate(async (errors: any) => {
		if (!errors) {
			await authStore.updateUserInfo(formValue.value)
			await authStore.queryUserInfo()
			useGlobalActions().msgSuccess(t("save_success"))
		}
	})
}

function setFormValue() {
	formValue.value.nickName = userInfo.value?.nickName ?? ""
	formValue.value.phonenumber = userInfo.value?.phonenumber ?? ""
	formValue.value.email = userInfo.value?.email ?? ""
	formValue.value.sex = userInfo.value?.sex ?? ""
}

watch(userInfo, () => {
	setFormValue()
})
onMounted(() => {
	setFormValue()
})
</script>

<style lang="scss" scoped>
.settings {
	.title {
		font-size: 20px;
		margin-bottom: 20px;

		&:not(:first-child) {
			margin-top: 20px;
		}
	}
}
</style>
