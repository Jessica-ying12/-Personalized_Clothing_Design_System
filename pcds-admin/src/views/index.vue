<template>
  <div class="p-6">
    <!-- 统计卡片 -->
    <n-grid :cols="4" :x-gap="16" :y-gap="16" class="mb-6">
      <n-gi v-for="card in statCards" :key="card.key">
        <n-card :style="{ borderTop: `3px solid ${card.color}` }" hoverable>
          <div class="flex items-center justify-between">
            <div>
              <div class="text-3xl font-bold" :style="{ color: card.color }">
                {{ stats ? (stats[card.key] ?? 0) : '—' }}
              </div>
              <div class="text-sm text-gray-500 mt-1">{{ card.label }}</div>
            </div>
            <Icon :name="card.icon" :size="40" :style="{ color: card.color, opacity: 0.3 }" />
          </div>
        </n-card>
      </n-gi>
    </n-grid>

    <!-- 快捷入口 -->
    <n-card title="快捷管理" class="mb-6">
      <n-grid :cols="4" :x-gap="12">
        <n-gi v-for="entry in quickEntries" :key="entry.path">
          <n-button block quaternary style="height:80px;flex-direction:column;gap:8px" @click="router.push(entry.path)">
            <Icon :name="entry.icon" :size="28" :style="{ color: entry.color }" />
            <span class="text-sm">{{ entry.label }}</span>
          </n-button>
        </n-gi>
      </n-grid>
    </n-card>

    <!-- 最近记录 -->
    <n-grid :cols="2" :x-gap="16">
      <n-gi>
        <n-card title="最近平面图（5条）">
          <n-data-table :columns="flatColumns" :data="recentFlat" :loading="loading" :pagination="false" size="small" />
        </n-card>
      </n-gi>
      <n-gi>
        <n-card title="最近立体图（5条）">
          <n-data-table :columns="d3Columns" :data="recentD3" :loading="loading" :pagination="false" size="small" />
        </n-card>
      </n-gi>
    </n-grid>
  </div>
</template>

<script lang="ts" setup>
import { h, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'
import { NButton, NCard, NDataTable, NGi, NGrid, NImage } from 'naive-ui'
import Icon from '@/components/common/Icon.vue'
import request from '@/utils/request'

const router = useRouter()
const stats = ref<any>(null)
const loading = ref(false)
const recentFlat = ref<any[]>([])
const recentD3 = ref<any[]>([])

const statCards = [
  { key: 'user_total',      label: '注册用户',   color: '#6A9BFA', icon: 'carbon:user-multiple' },
  { key: 'flat_total',      label: '平面图总数', color: '#CB8DEA', icon: 'carbon:image' },
  { key: 'design_3d_total', label: '立体图总数', color: '#4ECDC4', icon: 'carbon:cube' },
  { key: 'option_total',    label: '设计选项',   color: '#FF9F43', icon: 'carbon:settings' },
]

const quickEntries = [
  { label: '用户管理',     path: '/pcds/users',          color: '#6A9BFA', icon: 'carbon:user-multiple' },
  { label: '平面图管理',   path: '/pcds/flat-designs',   color: '#CB8DEA', icon: 'carbon:image' },
  { label: '立体图管理',   path: '/pcds/3d-designs',     color: '#4ECDC4', icon: 'carbon:cube' },
  { label: '设计选项管理', path: '/pcds/design-options', color: '#FF9F43', icon: 'carbon:settings' },
]

const flatColumns = [
  { title: 'ID', key: 'design_id', width: 60 },
  {
    title: '预览', key: 'image_url', width: 70,
    render: (row: any) => h(NImage, { src: row.image_url, width: 50, height: 60, objectFit: 'cover', style: 'border-radius:4px' }),
  },
  { title: '版型', key: 'clothing_type_code' },
  { title: '时间', key: 'created_at', ellipsis: { tooltip: true } },
]

const d3Columns = [
  { title: 'ID', key: 'design_id', width: 60 },
  {
    title: '预览', key: 'image_url', width: 70,
    render: (row: any) => h(NImage, { src: row.image_url, width: 50, height: 60, objectFit: 'cover', style: 'border-radius:4px' }),
  },
  { title: '性别', key: 'gender_code' },
  { title: '时间', key: 'created_at', ellipsis: { tooltip: true } },
]

onMounted(async () => {
  loading.value = true
  try {
    const [statsRes, flatRes, d3Res]: any[] = await Promise.all([
      request.get({ url: '/api/admin/stats' }, { isTransformResponse: false }),
      request.get({ url: '/api/admin/flat-designs', params: { page: 1, page_size: 5 } }, { isTransformResponse: false }),
      request.get({ url: '/api/admin/3d-designs', params: { page: 1, page_size: 5 } }, { isTransformResponse: false }),
    ])
    if (statsRes.code === 200) stats.value = statsRes.data
    if (flatRes.code === 200) recentFlat.value = flatRes.data?.data || []
    if (d3Res.code === 200) recentD3.value = d3Res.data?.data || []
  } finally {
    loading.value = false
  }
})
</script>
