<template>
  <div class="p-4">
    <n-card title="用户管理">
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
import { NButton, NTag, useMessage } from 'naive-ui'
import request from '@/utils/request'

const message = useMessage()
const loading = ref(false)
const tableData = ref([])
const pagination = ref({ page: 1, pageSize: 20, itemCount: 0, showSizePicker: true })

const columns = [
  { title: 'ID', key: 'user_id', width: 80 },
  { title: '邮箱', key: 'email' },
  { title: '昵称', key: 'nickname' },
  {
    title: '状态',
    key: 'status',
    render: (row: any) =>
      h(NTag, { type: row.status === '0' ? 'success' : 'error' }, () =>
        row.status === '0' ? '正常' : '停用'
      ),
  },
  { title: '注册时间', key: 'created_at' },
  {
    title: '操作',
    key: 'actions',
    render: (row: any) =>
      h(NButton, { size: 'small', type: 'error', onClick: () => handleDisable(row) }, () => '停用'),
  },
]

async function loadData() {
  loading.value = true
  try {
    const res: any = await request.get(
      { url: '/api/admin/users', params: { page: pagination.value.page, page_size: pagination.value.pageSize } },
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

async function handleDisable(row: any) {
  message.info(`停用用户 ${row.email}`)
}

onMounted(loadData)
</script>
