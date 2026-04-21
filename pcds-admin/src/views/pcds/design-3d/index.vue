<template>
  <div class="p-4">
    <n-card title="立体图管理">
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
import { NButton, NImage, useMessage } from 'naive-ui'
import request from '@/utils/request'

const message = useMessage()
const loading = ref(false)
const tableData = ref([])
const pagination = ref({ page: 1, pageSize: 20, itemCount: 0 })

const columns = [
  { title: 'ID', key: 'design_id', width: 80 },
  { title: '用户ID', key: 'user_id', width: 80 },
  { title: '平面图ID', key: 'flat_design_id', width: 100 },
  {
    title: '预览图',
    key: 'image_url',
    render: (row: any) =>
      h(NImage, { src: row.image_url, width: 60, height: 75, objectFit: 'cover' }),
  },
  { title: '身体类型', key: 'body_type_code' },
  { title: '肤色', key: 'skin_tone_code' },
  { title: '性别', key: 'gender_code' },
  { title: '背景', key: 'background_code' },
  { title: '生成时间', key: 'created_at' },
  {
    title: '操作',
    key: 'actions',
    render: (row: any) =>
      h(NButton, { size: 'small', type: 'error', onClick: () => handleDelete(row) }, () => '删除'),
  },
]

async function loadData() {
  loading.value = true
  try {
    const res: any = await request.get(
      { url: '/api/admin/3d-designs', params: { page: pagination.value.page, page_size: pagination.value.pageSize } },
      { isTransformResponse: false }
    )
    if (res.code === 200) {
      tableData.value = res.data?.data || []
      pagination.value.itemCount = res.data?.total || 0
    }
  } catch (e) {
    message.error('加载失败')
  } finally {
    loading.value = false
  }
}

function handlePageChange(page: number) {
  pagination.value.page = page
  loadData()
}

async function handleDelete(row: any) {
  message.info(`删除设计 ${row.design_id}`)
}

onMounted(loadData)
</script>
