<template>
	<!-- 修改密码表单 -->
	<n-card>
		<n-form ref="refForm" :label-width="80" :model="formValue" :rules="formRules">
			<n-form-item :label="t('old_password')" path="oldPassword" class="basis-1/2">
				<n-input
					v-model:value="formValue.oldPassword"
					type="password"
					size="large"
					show-password-on="click"
					:placeholder="t('please_input_old_password')"
				/>
			</n-form-item>
			<n-form-item :label="t('new_password')" path="newPassword" class="basis-1/2">
				<n-input
					v-model:value="formValue.newPassword"
					type="password"
					size="large"
					show-password-on="click"
					:placeholder="t('please_input_new_password')"
				/>
			</n-form-item>
			<n-form-item :label="t('confirm_password')" path="confirmPassword" class="basis-1/2">
				<n-input
					v-model:value="formValue.confirmPassword"
					type="password"
					size="large"
					show-password-on="click"
					:disabled="!formValue.newPassword"
					:placeholder="t('please_input_confirm_password')"
				/>
			</n-form-item>
			<n-form-item>
				<n-button type="primary" @click="handleSubmit">{{ t("save") }}</n-button>
			</n-form-item>
		</n-form>
	</n-card>
</template>

<script setup lang="ts">
import type { FormItemRule } from "naive-ui"
import { NButton, NCard, NForm, NFormItem, NInput } from "naive-ui"
import { reactive, ref } from "vue"
import { useGlobalActions } from "@/composables/useGlobalActions"
import { useAuthStore } from "@/stores/auth"

import { useLocalesStore } from "@/stores/i18n"

const localesStore = useLocalesStore()
const { t } = localesStore
const authStore = useAuthStore()

const refForm = ref()

const formValue = reactive({
	oldPassword: "",
	newPassword: "",
	confirmPassword: ""
})

const formRules = {
	oldPassword: [
		{
			required: true,
			message: t("please_input_old_password"),
			trigger: "blur"
		}
	],
	newPassword: [
		{
			required: true,
			message: t("please_input_new_password"),
			trigger: "blur"
		}
	],
	confirmPassword: [
		{
			required: true,
			trigger: ["blur"],
			message: t("auth_login_password_confirm_required")
		},
		{
			validator: (rule: FormItemRule, value: string): boolean => {
				return value === formValue.newPassword
			},
			message: t("auth_login_password_confirm_match"),
			trigger: ["blur", "password-input"]
		}
	]
}

function handleSubmit() {
	refForm.value.validate(async (errors: any) => {
		if (!errors) {
			const params = {
				oldPassword: formValue.oldPassword,
				newPassword: formValue.newPassword
			}
			await authStore.updateUserPwd(params).then(() => {
				useGlobalActions().msgSuccess(t("save_success"))
			})
		}
	})
}
</script>

<style scoped lang="scss"></style>
