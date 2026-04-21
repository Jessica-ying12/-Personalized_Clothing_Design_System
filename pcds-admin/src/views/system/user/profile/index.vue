<template>
	<div class="page">
		<n-card class="header flex flex-col" content-class="!p-0">
			<div class="user-info flex flex-wrap">
				<div class="propic">
					<n-avatar :size="100" :src="avatar" round :img-props="{ alt: 'avatar' }" />
				</div>
				<div class="info flex grow flex-col justify-center">
					<div class="name">
						<h1>{{ userInfo?.nickName }}</h1>
					</div>
					<div class="details flex flex-wrap">
						<div class="item">
							<n-tooltip placement="top">
								<template #trigger>
									<div class="tooltip-wrap">
										<Icon :name="RoleIcon" />
										<span>{{ roleName }}</span>
									</div>
								</template>
								<span>{{ $t("role") }}</span>
							</n-tooltip>
						</div>
						<div class="item">
							<n-tooltip placement="top">
								<template #trigger>
									<div class="tooltip-wrap">
										<Icon :name="LocationIcon" />
										<span>无</span>
									</div>
								</template>
								<span>{{ $t("location") }}</span>
							</n-tooltip>
						</div>
						<div class="item">
							<n-tooltip placement="top">
								<template #trigger>
									<div class="tooltip-wrap">
										<Icon :name="MailIcon" />
										<span>{{ userInfo?.email }}</span>
									</div>
								</template>
								<span>{{ $t("email") }}</span>
							</n-tooltip>
						</div>
					</div>
				</div>
				<div class="actions">
					<ImageCropper
						v-slot="{ openCropper }"
						:placeholder="$t('select_your_profile_picture')"
						@crop="setCroppedImage"
					>
						<n-button size="large" type="primary" @click="openCropper()">{{ $t("edit_profile_image") }}</n-button>
					</ImageCropper>
				</div>
			</div>
			<div class="section-selector">
				<n-tabs v-model:value="tabActive">
					<n-tab name="basicInformation">{{ $t("basic_information") }}</n-tab>
					<n-tab name="editPassword">{{ $t("edit_password") }}</n-tab>
				</n-tabs>
			</div>
		</n-card>
		<div class="main">
			<n-tabs v-model:value="tabActive" tab-class="!hidden" animated>
				<n-tab-pane name="basicInformation">
					<ProfileSettings />
				</n-tab-pane>
				<n-tab-pane name="editPassword">
					<PasswordEdit />
				</n-tab-pane>
			</n-tabs>
		</div>
	</div>
</template>

<script lang="ts" setup>
import type { ComputedRef } from "vue"
import type { ImageCropperResult } from "@/components/common/ImageCropper.vue"
import type { UserInfo } from "@/stores/auth"
import { NAvatar, NButton, NCard, NTab, NTabPane, NTabs, NTooltip } from "naive-ui"
import { computed, ref } from "vue"
import Icon from "@/components/common/Icon.vue"
import ImageCropper from "@/components/common/ImageCropper.vue"
import PasswordEdit from "@/components/profile/PasswordEdit.vue"
import ProfileSettings from "@/components/profile/ProfileSettings.vue"
import { useGlobalActions } from "@/composables/useGlobalActions.ts"

import { useAuthStore } from "@/stores/auth"
import { base642File } from "@/utils"
import { userApi } from "@/views/system/user/api/user.ts"

const authStore = useAuthStore()
const userInfo: ComputedRef<UserInfo | null> = computed(() => authStore.userInfo)
const avatar = computed(() => authStore.getAvatar())

const roleName = computed(() => {
	if (userInfo.value && userInfo.value.role && userInfo.value.role.length > 0) {
		return userInfo.value.role[0].roleName
	} else {
		return "无"
	}
})

const RoleIcon = "tabler:user"
const LocationIcon = "tabler:map-pin"
const MailIcon = "tabler:mail"

const tabActive = ref("basicInformation")

async function setCroppedImage(result: ImageCropperResult) {
	const canvas = result.canvas as HTMLCanvasElement
	const avatarFile = await base642File(canvas.toDataURL(), "avatar.jpg")
	const formData = new FormData()
	formData.append("avatarfile", avatarFile)
	userApi.uploadAvatar(formData).then(res => {
		if (res.code === 200) {
			authStore.setAvatar(res.imgUrl)
		} else {
			useGlobalActions().msgError(res.msg)
		}
	})
}
</script>

<style lang="scss" scoped>
.page {
	.header {
		.user-info {
			gap: 30px;
			padding: 30px;
			padding-bottom: 20px;
			border-block-end: 1px solid var(--border-color);
			container-type: inline-size;

			.propic {
				position: relative;
				height: 100px;

				.edit {
					display: none;
					align-items: center;
					justify-content: center;
					background-color: var(--primary-color);
					color: var(--bg-default-color);
					position: absolute;
					width: 26px;
					height: 26px;
					border-radius: 50%;
					top: -1px;
					right: -1px;
					border: 1px solid var(--bg-default-color);
					cursor: pointer;
				}
			}
			.info {
				.name {
					margin-bottom: 12px;

					@media (max-width: 450px) {
						h1 {
							font-size: 28px;
						}
					}
				}

				.details {
					gap: 24px;

					.item {
						.tooltip-wrap {
							display: flex;
							align-items: center;
							gap: 8px;
							line-height: 1;
						}
					}
				}
			}

			@container (max-width: 900px) {
				.propic {
					.edit {
						display: flex;
					}
				}
				.actions {
					display: none;
				}
			}
		}
		.section-selector {
			padding: 0px 30px;
			padding-top: 15px;

			:deep() {
				.n-tabs .n-tabs-tab {
					padding-bottom: 20px;
				}
			}
		}
	}

	.main {
		margin-top: 18px;
	}
}
</style>
