<template>
	<div>
		<n-form ref="formRef" :model :rules>
			<n-form-item path="username" :label="$t('auth_login_username')" first>
				<n-input
					v-model:value="model.username"
					:placeholder="$t('auth_login_username_placeholder')"
					size="large"
					autocomplete="on"
					@keydown.enter="signIn"
				/>
			</n-form-item>
			<n-form-item path="password" :label="$t('auth_login_password')">
				<n-input
					v-model:value="model.password"
					type="password"
					show-password-on="click"
					:placeholder="$t('auth_login_password_placeholder')"
					autocomplete="on"
					size="large"
					@keydown.enter="signIn"
				/>
			</n-form-item>
			<n-form-item v-if="captchaEnabled" path="code" :label="$t('auth_login_code')">
				<n-input-group>
					<n-input
						v-model:value="model.code"
						:placeholder="$t('auth_login_code_required')"
						size="large"
						@keydown.enter="signIn"
					/>
					<img :src="codeUrl" class="login-code-img" @click="getCode()" />
				</n-input-group>
			</n-form-item>
			<div class="flex flex-col items-end gap-6">
				<div class="flex w-full justify-between">
					<n-checkbox size="large">{{ $t("auth_login_remember_password") }}</n-checkbox>
					<slot name="extra-actions" />
				</div>
				<div class="w-full">
					<n-button
						type="primary"
						class="w-full!"
						size="large"
						:loading="loading"
						:disabled="!isValid"
						@click="signIn"
					>
						{{ $t("auth_login_btn") }}
					</n-button>
				</div>
			</div>
		</n-form>

		<n-divider v-if="false" title-placement="center">Or</n-divider>

		<div v-if="false" class="social-btns mb-12 flex flex-col gap-4">
			<n-button strong secondary size="large">
				<template #icon>
					<img alt="google-icon" class="block h-5" src="@/assets/images/google-icon.svg?url" />
				</template>
				<span class="px-2">Sign in with Google</span>
			</n-button>
			<n-button strong secondary size="large">
				<template #icon>
					<img alt="facebook-icon" class="block h-5" src="@/assets/images/facebook-icon.svg?url" />
				</template>
				<span class="px-2">Sign in with Facebook</span>
			</n-button>
		</div>

		<slot name="bottom-area" />
	</div>
</template>

<script lang="ts" setup>
import { type FormInst, type FormRules, type FormValidationError, NInputGroup } from "naive-ui"
import { NButton, NCheckbox, NDivider, NForm, NFormItem, NInput } from "naive-ui"
import { computed, onMounted, ref, watch } from "vue"
import { useRouter } from "vue-router"
import { useGlobalActions } from "@/composables/useGlobalActions.ts"
import { useAuthStore } from "@/stores/auth"
import { useLocalesStore } from "@/stores/i18n"
import cache from "@/utils/cache"
import { GeetestUtils } from "@/utils/geetestUtils"
import { authApi } from "@/views/Auth/api/auth.ts"

interface ModelType {
	username: string | null
	password: string | null
	code: string | null
	uuid: string | null
	captchaToken: string | null
}

const { t } = useLocalesStore()
const router = useRouter()
const loading = ref(false)
const formRef = ref<FormInst | null>(null)
const authStore = useAuthStore()

// 验证码开关
const captchaEnabled = ref(true)
// 注册开关
const register = ref(false)
const codeUrl = ref("")
const rememberMe = ref(false)

const model = ref<ModelType>({
	username: null,
	password: null,
	code: null,
	uuid: null,
	captchaToken: null
})

const rules: FormRules = {
	username: [
		{
			required: true,
			trigger: ["blur"],
			message: t("auth_login_username_required")
		}
	],
	password: [
		{
			required: true,
			trigger: ["blur"],
			message: t("auth_login_password_required")
		}
	]
}

const isValid = computed(() => {
	return model.value.password && model.value.username && (!captchaEnabled.value || model.value.code)
})

function getCode() {
	authApi.captcha().then(res => {
		captchaEnabled.value = res.captchaEnabled === undefined ? true : res.captchaEnabled
		register.value = res.registerEnabled === undefined ? false : res.registerEnabled
		codeUrl.value = `data:image/gif;base64,${res.img}`
		model.value.uuid = res.uuid
	})
}

function signIn(e: Event) {
	e.preventDefault()
	formRef.value?.validate(async (errors: Array<FormValidationError> | undefined) => {
		if (!errors) {
			if (captchaEnabled.value && model.value.code === null) {
				useGlobalActions().msgError(t("auth_login_code_required"))
				return
			}
			if (captchaEnabled.value) {
				// eslint-disable-next-line ts/no-use-before-define
				geetestUtils.showCaptcha()
			} else {
				loading.value = true
				doLogin()
			}
		} else {
			useGlobalActions().msgError("Invalid credentials")
		}
	})
}

function doLogin() {
	if (rememberMe.value) {
		cache.set("username", model.value.username || "")
		cache.set("password", model.value.password || "")
	} else {
		cache.set("username", "")
		cache.set("password", "")
	}
	authStore
		.setLogged({ email: model.value.username!, password: model.value.password! })
		.then(() => {
			router.push({ path: "/", replace: true })
		})
		.catch(err => {
			getCode()
			useGlobalActions().msgError(err)
		})
		.finally(() => {
			loading.value = false
		})
}

watch(isValid, val => {
	if (val) {
		formRef.value?.validate()
	}
})

// ---------- 滑动验证码处理 -----------
function handleCaptchaSuccess(result: any) {
	const data = {
		lot_number: result.lot_number,
		captcha_output: result.captcha_output,
		pass_token: result.pass_token,
		gen_time: result.gen_time
	}
	model.value.captchaToken = result.lot_number
	loading.value = true
	authApi.captchaCheck(data).then(res => {
		if (res === true) {
			doLogin()
		} else {
			useGlobalActions().msgError("验证失败，请重试")
			loading.value = false
		}
	})
}

let geetestUtils: GeetestUtils

onMounted(() => {
	geetestUtils = new GeetestUtils(undefined, undefined, handleCaptchaSuccess)
	geetestUtils
		.initCaptcha()
		.then(() => {})
		.catch(error => {
			console.error("验证码初始化失败:", error)
		})

	getCode()
	const username = cache.get("username")
	const password = cache.get("password")
	if (username && password) {
		rememberMe.value = true
		model.value.password = password
		model.value.username = username
	}
})
</script>

<style scoped lang="scss">
.login-code-img {
	height: auto;
	width: 100px;
	border-radius: 6px;
}

// 覆盖浏览器自动填充样式
:deep(input:-webkit-autofill),
:deep(input:-webkit-autofill:hover),
:deep(input:-webkit-autofill:focus),
:deep(input:-webkit-autofill:active) {
	-webkit-box-shadow: 0 0 0 30px white inset !important;
	-webkit-text-fill-color: inherit !important;
	transition: background-color 5000s ease-in-out 0s;
}
</style>
