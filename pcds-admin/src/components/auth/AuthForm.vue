<template>
	<div class="w-full max-w-96 min-w-64">
		<n-collapse-transition :show="type === 'forgotpassword'">
			<n-button text @click="gotoSignIn">
				<Icon name="carbon:arrow-left" :size="30" />
			</n-button>
		</n-collapse-transition>

		<div class="my-10">
			<Logo mini :dark="isDark" class="mb-4" max-height="40px" />
			<div class="font-display mb-4 text-4xl font-bold" v-if="false">{{ title }}</div>
			<div class="text-secondary mb-12 text-lg">
				{{ $t("auth_login_message") }}
			</div>
		</div>

		<transition name="form-fade" mode="out-in" appear class="min-h-137">
			<SignIn v-if="type === 'signin'" key="signin">
				<template #extra-actions>
					<n-button v-if="false" text type="primary" @click="gotoForgotPassword()">Forgot Password?</n-button>
				</template>
				<template #bottom-area>
					<div class="text-center" v-if="false">
						Don't you have an account?
						<n-button text type="primary" size="large" @click="gotoSignUp()">Sign up</n-button>
					</div>
				</template>
			</SignIn>
			<SignUp v-else-if="type === 'signup'" key="signup">
				<template #bottom-area>
					<div class="text-center">
						Do you have an account?
						<n-button text type="primary" size="large" @click="gotoSignIn()">Sign in</n-button>
					</div>
				</template>
			</SignUp>
			<ForgotPassword v-else-if="type === 'forgotpassword'" key="forgotpassword" />
		</transition>
	</div>
</template>

<script lang="ts" setup>
import type { FormType } from "./types.d"
import { NButton, NCollapseTransition } from "naive-ui"
import { computed, onBeforeMount, ref } from "vue"
import { useRouter } from "vue-router"
import Logo from "@/app-layouts/common/Logo.vue"
import Icon from "@/components/common/Icon.vue"
import { useThemeStore } from "@/stores/theme"
import ForgotPassword from "./ForgotPassword.vue"
import SignIn from "./SignIn.vue"
import SignUp from "./SignUp.vue"

const props = defineProps<{
	type?: FormType
	useOnlyRouter?: boolean
}>()

const type = ref<FormType>("signin")
const router = useRouter()
const themeStore = useThemeStore()
const isDark = computed<boolean>(() => themeStore.isThemeDark)
const title = computed<string>(() =>
	type.value === "signin" ? "Welcome Back" : type.value === "signup" ? "Hello" : "Forgot Password"
)

function gotoSignIn() {
	if (!props.useOnlyRouter) {
		type.value = "signin"
	} else {
		router.replace({ name: "Login" })
	}
}

function gotoSignUp() {
	if (!props.useOnlyRouter) {
		type.value = "signup"
	} else {
		router.replace({ name: "Register" })
	}
}

function gotoForgotPassword() {
	if (!props.useOnlyRouter) {
		type.value = "forgotpassword"
	} else {
		router.replace({ name: "ForgotPassword" })
	}
}

onBeforeMount(() => {
	if (props.type) {
		type.value = props.type
	}
})
</script>

<style lang="scss" scoped>
.form-fade-enter-active,
.form-fade-leave-active {
	transition:
		opacity 0.2s ease-in-out,
		transform 0.3s ease-in-out;
}
.form-fade-enter-from {
	opacity: 0;
	transform: translateX(10px);
}
.form-fade-leave-to {
	opacity: 0;
	transform: translateX(-10px);
}
</style>
