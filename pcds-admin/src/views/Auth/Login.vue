<template>
	<div class="page-auth">
		<Settings v-show="false" v-model:align="align" v-model:active-color="activeColor" style="z-index: 999" />

		<div v-if="!isLogged" class="wrapper flex justify-center">
			<div v-if="align === 'right'" class="image-box basis-2/3">
				<div class="floating-shapes"></div>
				<div class="background-pattern"></div>
				<div class="title-container">
					<div class="title-wrap">
						<h1 class="main-title">Hammer - 管理台</h1>
						<h2 class="sub-title">MANAGEMENT PLATFORM</h2>
						<div class="decorative-line"></div>
					</div>
				</div>
			</div>
			<div class="form-box flex basis-1/3 items-center justify-center" :class="{ centered: align === 'center' }">
				<AuthForm :type="type" />
			</div>
			<div v-if="align === 'left'" class="image-box basis-2/3">
				<div class="floating-shapes"></div>
				<div class="background-pattern"></div>
				<div class="title-container">
					<div class="title-wrap">
						<h1 class="main-title">Unicom - 管理台</h1>
						<h2 class="sub-title">MANAGEMENT PLATFORM</h2>
						<div class="decorative-line"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</template>

<script lang="ts" setup>
import type { Align } from "@/components/auth/Settings.vue"
import type { FormType } from "@/components/auth/types.d"
import { computed, onBeforeMount, ref } from "vue"
import { useRoute } from "vue-router"
import AuthForm from "@/components/auth/AuthForm.vue"
import Settings from "@/components/auth/Settings.vue"
import { useAuthStore } from "@/stores/auth"

const { formType } = defineProps<{
	formType?: FormType
}>()

const route = useRoute()
const align = ref<Align>("right")
const activeColor = ref("")
const type = ref<FormType | undefined>(formType || undefined)
const authStore = useAuthStore()
const isLogged = computed(() => authStore.isLogged)

onBeforeMount(() => {
	if (route.query.step) {
		const step = route.query.step as FormType
		type.value = step
	}
})
</script>

<style lang="scss" scoped>
@import "./main.scss";

.page-auth {
	.wrapper {
		.image-box {
			background-color: v-bind(activeColor);
		}
	}
}
</style>
