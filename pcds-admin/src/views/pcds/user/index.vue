<template>
  <div class="p-4">
    <n-card title="用户管理">
      <template #header-extra>
        <n-input
          v-model:value="keyword"
          placeholder="搜索邮箱/昵称"
          clearable
          style="width: 220px"
          @keydown.enter="handleSearch"
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
import { NAvatar, NButton, NCard, NDataTable, NInput, NPopconfirm, NSpace, NTag, useMessage } from 'naive-ui'
import request from '@/utils/request'

const message = useMessage()
const loading = ref(false)
const tableData = ref<any[]>([])
const keyword = ref('')
const pagination = ref({ page: 1, pageSize: 20, itemCount: 0, showSizePicker: true, pageSizes: [10, 20, 50] })

const columns = [
  { title: 'ID', key: 'user_id', width: 70 },
  {
    title: '头像', key: 'avatar_url', width: 70,
    render: (row: any) => h(NAvatar, {
      src: row.avatar_url || undefined,
      round: true, size: 36,
      style: 'background:#6A9BFA',
    }, row.avatar_url ? undefined : () => (row.nickname || row.email || '?')[0].toUpperCase()),
  },
  { title: '邮箱', key: 'email', ellipsis: { tooltip: true } },
  { title: '昵称', key: 'nickname' },
  {
    title: '状态', key: 'status', width: 90,
    render: (row: any) => h(NTag, { type: row.status === '0' ? 'success' : 'error', size: 'small' },
      () => row.status === '0' ? '正常' : '停用'),
  },
  { title: '注册时间', key: 'created_at', width: 180 },
  {
    title: '操作', key: 'actions', width: 160,
    render: (row: any) => h(NSpace, {}, () => [
      h(NButton, {
        size: 'small',
        type: row.status === '0' ? 'warning' : 'success',
        onClick: () => handleToggleStatus(row),
      }, () => row.status === '0' ? '停用' : '启用'),
      h(NPopconfirm, { onPositiveClick: () => handleDelete(row) }, {
        default: () => `确定删除用户 ${row.email}？`,
        trigger: () => h(NButton, { size: 'small', type: 'error' }, () => '删除'),
      }),
    ]),
  },
]

async function loadData() {
  loading.value = true
  try {
    const res: any = await request.get(
      { url: '/api/admin/users', params: { page: pagination.value.page, page_size: pagination.value.pageSize, keyword: keyword.value || undefined } },
      { isTransformResponse: false }
    )
    if (res.code === 200) {
      tableData.value = res.data?.data || []
      pagination.value.itemCount = res.data?.total || 0
    }
  } catch { message.error('加载失败') }
  finally { loading.value = false }
}

function handleSearch() { pagination.value.page = 1; loadData() }
function handlePageChange(page: number) { pagination.value.page = page; loadData() }

async function handleToggleStatus(row: any) {
  try {
    const res: any = await request.put({ url: `/api/admin/users/${row.user_id}/status` }, { isTransformResponse: false })
    if (res.code === 200) { message.success('操作成功'); loadData() }
  } catch { message.error('操作失败') }
}

async function handleDelete(row: any) {
  try {
    const res: any = await request.delete({ url: `/api/admin/users/${row.user_id}` }, { isTransformResponse: false })
    if (res.code === 200) { message.success('删除成功'); loadData() }
  } catch { message.error('删除失败') }
}

onMounted(loadData)
</script>
