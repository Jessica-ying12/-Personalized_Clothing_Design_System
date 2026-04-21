<template>
  <div class="p-4">
    <n-card title="设计选项管理">
      <template #header-extra>
        <n-select
          v-model:value="selectedCategory"
          :options="categoryOptions"
          placeholder="筛选类别"
          clearable
          style="width: 200px"
          @update:value="loadData"
        />
      </template>
      <n-data-table
        :columns="columns"
        :data="tableData"
        :loading="loading"
      />
    </n-card>
  </div>
</template>

<script setup lang="ts">
import { h, onMounted, ref } from 'vue'
import { NTag, useMessage } from 'naive-ui'
import request from '@/utils/request'

const message = useMessage()
const loading = ref(false)
const tableData = ref([])
const selectedCategory = ref<string | null>(null)

const categoryOptions = [
  { label: '版型', value: 'clothing_type' },
  { label: '花纹', value: 'pattern' },
  { label: '材质', value: 'material' },
  { label: '风格', value: 'style' },
  { label: '受众', value: 'audience' },
  { label: 'AI模型', value: 'ai_model' },
  { label: '身体类型', value: 'body_type' },
  { label: '肤色', value: 'skin_tone' },
  { label: '性别', value: 'gender' },
  { label: '背景', value: 'background' },
  { label: '颜色', value: 'color' },
]

const columns = [
  { title: 'ID', key: 'option_id', width: 80 },
  { title: '代码', key: 'option_code' },
  { title: '类别', key: 'category' },
  { title: '中文名', key: 'name_zh' },
  { title: '英文名', key: 'name_en' },
  { title: '父级ID', key: 'parent_id' },
  { title: '排序', key: 'sort_order', width: 80 },
  {
    title: '状态',
    key: 'status',
    render: (row: any) =>
      h(NTag, { type: row.status === '0' ? 'success' : 'default' }, () =>
        row.status === '0' ? '启用' : '停用'
      ),
  },
]

async function loadData() {
  loading.value = true
  try {
    const params: any = {}
    if (selectedCategory.value) params.category = selectedCategory.value
    const res: any = await request.get(
      { url: '/api/design-options/list', params },
      { isTransformResponse: false }
    )
    if (res.code === 200) {
      tableData.value = res.data || []
    }
  } catch (e) {
    message.error('加载失败')
  } finally {
    loading.value = false
  }
}

onMounted(loadData)
</script>
