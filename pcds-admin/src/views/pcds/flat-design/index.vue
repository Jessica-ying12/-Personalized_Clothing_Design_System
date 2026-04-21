<template>
  <div class="p-4">
    <n-card title="平面图管理">
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

    <!-- 图片预览弹窗 -->
    <n-modal v-model:show="showPreview" preset="card" title="图片预览" style="width:400px">
      <n-image :src="previewUrl" width="360" style="border-radius:8px" />
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { h, onMounted, ref } from 'vue'
import { NButton, NCard, NDataTable, NInputNumber, NModal, NImage, NPopconfirm, NTag, useMessage } from 'naive-ui'
import request from '@/utils/request'
import { cn } from '../codeMap'

const message = useMessage()
const loading = ref(false)
const tableData = ref<any[]>([])
const filterUserId = ref<number | null>(null)
const pagination = ref({ page: 1, pageSize: 20, itemCount: 0 })
const showPreview = ref(false)
const previewUrl = ref('')

const columns = [
  { title: 'ID', key: 'design_id', width: 70 },
  { title: '用户ID', key: 'user_id', width: 80 },
  {
    title: '预览图', key: 'image_url', width: 80,
    render: (row: any) => h(NImage, {
      src: row.image_url, width: 56, height: 70, objectFit: 'cover',
      style: 'border-radius:6px;cursor:pointer',
      previewDisabled: true,
      onClick: () => { previewUrl.value = row.image_url; showPreview.value = true },
    }),
  },
  { title: '版型', key: 'clothing_type_code', render: (row: any) => cn(row.clothing_type_code) },
  { title: '花纹', key: 'pattern_code', render: (row: any) => cn(row.pattern_code) },
  { title: '材质', key: 'material_code', render: (row: any) => cn(row.material_code) },
  { title: '风格', key: 'style_code', render: (row: any) => cn(row.style_code) },
  { title: '颜色', key: 'color_code', render: (row: any) => cn(row.color_code) },
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
      default: () => '确定删除此平面图？',
      trigger: () => h(NButton, { size: 'small', type: 'error' }, () => '删除'),
    }),
  },
]

async function loadData() {
  loading.value = true
  try {
    const params: any = { page: pagination.value.page, page_size: pagination.value.pageSize }
    if (filterUserId.value) params.user_id = filterUserId.value
    const res: any = await request.get({ url: '/api/admin/flat-designs', params }, { isTransformResponse: false })
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
    const res: any = await request.delete({ url: `/api/admin/flat-designs/${row.design_id}` }, { isTransformResponse: false })
    if (res.code === 200) { message.success('删除成功'); loadData() }
  } catch { message.error('删除失败') }
}

onMounted(loadData)
</script>
