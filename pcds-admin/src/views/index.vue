<template>
  <div class="page w-full h-full" :class="{ 'dark-mode': isDark }">
    <div class="container">
      <div class="logo-icon">👗</div>
      <div class="title">个性化服装设计系统</div>
      <div class="subtitle">管理后台</div>
      <div class="stats-row" v-if="stats">
        <div class="stat-item">
          <div class="stat-value">{{ stats.user_total }}</div>
          <div class="stat-label">注册用户</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ stats.flat_total }}</div>
          <div class="stat-label">平面图总数</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ stats.design_3d_total }}</div>
          <div class="stat-label">立体图总数</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, ref } from 'vue'
import { useThemeStore } from '@/stores/theme.ts'
import request from '@/utils/request'

const themeStore = useThemeStore()
const isDark = computed<boolean>(() => themeStore.isThemeDark)
const stats = ref<any>(null)

onMounted(async () => {
  try {
    const res: any = await request.get(
      { url: '/api/admin/stats' },
      { isTransformResponse: false }
    )
    if (res.code === 200) stats.value = res.data
  } catch (_) {}
})
</script>

<style lang="scss" scoped>
.page {
  display: flex;
  justify-content: center;
  align-items: center;
  background-color: #f5f7fa;
  transition: background-color 0.3s, color 0.3s;

  .container {
    display: flex;
    align-items: center;
    flex-direction: column;
    justify-content: center;
    padding: 40px;
    width: 100%;
    height: 80vh;
    border-radius: 14px;
    border: 2px dashed var(--border-color);
    transition: border-color 0.3s;
  }

  .logo-icon { font-size: 64px; margin-bottom: 16px; }

  .title {
    font-size: 3vw;
    font-weight: bold;
    color: #333;
    margin-bottom: 8px;
    font-family: 'Helvetica Neue', sans-serif;
    transition: color 0.3s;
  }

  .subtitle {
    font-size: 1.8vw;
    color: #666;
    margin-bottom: 40px;
    font-family: 'Helvetica Neue', sans-serif;
    transition: color 0.3s;
  }

  .stats-row {
    display: flex;
    gap: 48px;

    .stat-item {
      text-align: center;

      .stat-value {
        font-size: 2.5vw;
        font-weight: bold;
        color: #6A9BFA;
      }

      .stat-label {
        font-size: 14px;
        color: #999;
        margin-top: 4px;
      }
    }
  }
}

.dark-mode {
  background-color: #1a1a1a;

  .container { border-color: #444; }

  .title, .subtitle { color: #e6e6e6; }
}
</style>
