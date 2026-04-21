<template>
  <div class="p-4">
    <n-card title="立体图管理">
      <template #header-extra>
        <n-input-number
          v-model:value="filterUserId"
          placeholder="按用户ID筛选"
          clearable
          :show-button="false"
          style="width: 160px"
          @update:value="handleSearch"
        />
      </template>

      <n-data-table
        :columns="columns"
        :data="tableData"
        :loading="loading"
        :pagination="pagination"
        remote
        @update:page="handlePageChange"
      />
    </n-card>
  </div>
</template>

<script setup lang="ts">
import { h, onMounted, ref } from 'vue'
import { NButton, NCard, NDataTable, NInputNumber, NImage, NPopconfirm, NTag, useMessage } from 'naive-ui'
import request from '@/utils/request'
import { cn } from '../codeMap'

const message = useMessage()
const loading = ref(false)
const tableData = ref<any[]>([])
const filterUserId = ref<number | null>(null)
const pagination = ref({ page: 1, pageSize: 20, itemCount: 0 })

const columns = [
  { title: 'ID', key: 'design_id', width: 70 },
  { title: '用户ID', key: 'user_id', width: 80 },
  { title: '平面图ID', key: 'flat_design_id', width: 90 },
  {
    title: '预览图', key: 'image_url', width: 80,
    render: (row: any) => h(NImage, {
      src: row.image_url, width: 56, height: 70, objectFit: 'cover',
      style: 'border-radius:6px',
    }),
  },
  { title: '身体类型', key: 'body_type_code', render: (row: any) => cn(row.body_type_code) },
  { title: '肤色', key: 'skin_tone_code', render: (row: any) => cn(row.skin_tone_code) },
  { title: '性别', key: 'gender_code', render: (row: any) => cn(row.gender_code) },
  { title: '背景', key: 'background_code', render: (row: any) => cn(row.background_code) },
  {
    title: '已保存', key: 'is_saved', width: 80,
    render: (row: any) => h(NTag, { type: row.is_saved ? 'success' : 'default', size: 'small' },
      () => row.is_saved ? '是' : '否'),
  },
  { title: '重生成', key: 'regen_count', width: 80 },
  { title: '生成时间', key: 'created_at', width: 180 },
  {
    title: '操作', key: 'actions', width: 80,
    render: (row: any) => h(NPopconfirm, { onPositiveClick: () => handleDelete(row) }, {
      default: () => '确定删除此立体图？',
      trigger: () => h(NButton, { size: 'small', type: 'error' }, () => '删除'),
    }),
  },
]

async function loadData() {
  loading.value = true
  try {
    const params: any = { page: pagination.value.page, page_size: pagination.value.pageSize }
    if (filterUserId.value) params.user_id = filterUserId.value
    const res: any = await request.get({ url: '/api/admin/3d-designs', params }, { isTransformResponse: false })
    if (res.code === 200) {
      tableData.value = res.data?.data || []
      pagination.value.itemCount = res.data?.total || 0
    }
  } catch { message.error('加载失败') }
  finally { loading.value = false }
}

function handleSearch() { pagination.value.page = 1; loadData() }
function handlePageChange(page: number) { pagination.value.page = page; loadData() }

async function handleDelete(row: any) {
  try {
    const res: any = await request.delete({ url: `/api/admin/3d-designs/${row.design_id}` }, { isTransformResponse: false })
    if (res.code === 200) { message.success('删除成功'); loadData() }
  } catch { message.error('删除失败') }
}

onMounted(loadData)
</script>
