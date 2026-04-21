<template>
  <div class="p-4">
    <n-card title="设计选项管理">
      <template #header-extra>
        <n-button type="primary" @click="openCreate">+ 新增选项</n-button>
      </template>

      <!-- 分类 Tab -->
      <n-tabs v-model:value="activeCategory" type="line" animated @update:value="onTabChange">
        <n-tab-pane v-for="cat in categoryOptions" :key="cat.value" :name="cat.value" :tab="cat.label">
          <div class="flex gap-3 mb-3 mt-2">
            <n-input
              v-model:value="keyword"
              placeholder="搜索名称/代码"
              clearable
              style="width: 200px"
              @keydown.enter="loadData"
            />
            <n-button @click="loadData">搜索</n-button>
          </div>

          <n-data-table
            :columns="columns"
            :data="tableData"
            :loading="loading"
            :pagination="{ pageSize: 20 }"
            size="small"
          />
        </n-tab-pane>
      </n-tabs>
    </n-card>

    <!-- 新增/编辑弹窗 -->
    <n-modal v-model:show="showModal" preset="card" :title="editingId ? '编辑选项' : '新增选项'" style="width:480px">
      <n-form ref="formRef" :model="form" :rules="rules" label-placement="left" label-width="80">
        <n-form-item label="类别" path="category">
          <n-select v-model:value="form.category" :options="categoryOptions" :disabled="!!editingId" />
        </n-form-item>
        <n-form-item label="选项代码" path="option_code">
          <n-input v-model:value="form.option_code" :disabled="!!editingId" placeholder="如 ct_tshirt" />
        </n-form-item>
        <n-form-item label="中文名" path="name_zh">
          <n-input v-model:value="form.name_zh" placeholder="如 T恤" />
        </n-form-item>
        <n-form-item label="英文名" path="name_en">
          <n-input v-model:value="form.name_en" placeholder="如 T-Shirt" />
        </n-form-item>
        <n-form-item label="父级代码">
          <n-input v-model:value="form.parent_code" placeholder="可选，如 ct_top" clearable />
        </n-form-item>
        <n-form-item label="排序">
          <n-input-number v-model:value="form.sort_order" :min="0" style="width:100%" />
        </n-form-item>
        <n-form-item v-if="editingId" label="状态">
          <n-select v-model:value="form.status" :options="[{label:'启用',value:'0'},{label:'停用',value:'1'}]" />
        </n-form-item>
      </n-form>
      <template #footer>
        <n-space justify="end">
          <n-button @click="showModal = false">取消</n-button>
          <n-button type="primary" :loading="saving" @click="handleSave">保存</n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { h, onMounted, ref, reactive } from 'vue'
import { NButton, NCard, NDataTable, NForm, NFormItem, NInput, NInputNumber, NModal,
  NPopconfirm, NSelect, NSpace, NTab, NTabPane, NTabs, NTag, useMessage } from 'naive-ui'
import request from '@/utils/request'

const message = useMessage()
const loading = ref(false)
const saving = ref(false)
const tableData = ref<any[]>([])
const activeCategory = ref('clothing_type')
const keyword = ref('')
const showModal = ref(false)
const editingId = ref<number | null>(null)
const formRef = ref()

const form = reactive({
  category: '', option_code: '', name_zh: '', name_en: '',
  parent_code: '', sort_order: 0, status: '0',
})

const rules = {
  category: [{ required: true, message: '请选择类别' }],
  option_code: [{ required: true, message: '请输入选项代码' }],
  name_zh: [{ required: true, message: '请输入中文名' }],
  name_en: [{ required: true, message: '请输入英文名' }],
}

const categoryOptions = [
  { label: '服装类型', value: 'clothing_type' },
  { label: '花纹',     value: 'pattern' },
  { label: '材质',     value: 'material' },
  { label: '风格',     value: 'style' },
  { label: '受众',     value: 'audience' },
  { label: 'AI模型',   value: 'ai_model' },
  { label: '身体类型', value: 'body_type' },
  { label: '肤色',     value: 'skin_tone' },
  { label: '性别',     value: 'gender' },
  { label: '背景',     value: 'background' },
  { label: '颜色',     value: 'color' },
]

const columns = [
  { title: 'ID', key: 'option_id', width: 70 },
  { title: '代码', key: 'option_code', width: 160 },
  { title: '中文名', key: 'name_zh', width: 120 },
  { title: '英文名', key: 'name_en', width: 140 },
  { title: '父级', key: 'parent_code', width: 120,
    render: (row: any) => row.parent_code || '—' },
  { title: '排序', key: 'sort_order', width: 70 },
  {
    title: '状态', key: 'status', width: 80,
    render: (row: any) => h(NTag, { type: row.status === '0' ? 'success' : 'default', size: 'small' },
      () => row.status === '0' ? '启用' : '停用'),
  },
  {
    title: '操作', key: 'actions', width: 140,
    render: (row: any) => h(NSpace, {}, () => [
      h(NButton, { size: 'small', onClick: () => openEdit(row) }, () => '编辑'),
      h(NPopconfirm, { onPositiveClick: () => handleDelete(row) }, {
        default: () => `确定删除「${row.name_zh}」？`,
        trigger: () => h(NButton, { size: 'small', type: 'error' }, () => '删除'),
      }),
    ]),
  },
]

function onTabChange() {
  keyword.value = ''
  loadData()
}

async function loadData() {
  loading.value = true
  try {
    const params: any = { category: activeCategory.value }
    if (keyword.value) params.keyword = keyword.value
    const res: any = await request.get({ url: '/api/admin/design-options', params }, { isTransformResponse: false })
    if (res.code === 200) tableData.value = res.data || []
  } catch { message.error('加载失败') }
  finally { loading.value = false }
}

function openCreate() {
  editingId.value = null
  Object.assign(form, {
    category: activeCategory.value, option_code: '', name_zh: '', name_en: '',
    parent_code: '', sort_order: 0, status: '0',
  })
  showModal.value = true
}

function openEdit(row: any) {
  editingId.value = row.option_id
  Object.assign(form, {
    category: row.category, option_code: row.option_code,
    name_zh: row.name_zh, name_en: row.name_en,
    parent_code: row.parent_code || '', sort_order: row.sort_order, status: row.status,
  })
  showModal.value = true
}

async function handleSave() {
  await formRef.value?.validate()
  saving.value = true
  try {
    let res: any
    if (editingId.value) {
      res = await request.put(
        { url: `/api/admin/design-options/${editingId.value}`, data: { name_zh: form.name_zh, name_en: form.name_en, sort_order: form.sort_order, status: form.status } },
        { isTransformResponse: false }
      )
    } else {
      res = await request.post(
        { url: '/api/admin/design-options', data: { category: form.category, option_code: form.option_code, name_zh: form.name_zh, name_en: form.name_en, parent_code: form.parent_code || undefined, sort_order: form.sort_order } },
        { isTransformResponse: false }
      )
    }
    if (res.code === 200) {
      message.success(editingId.value ? '修改成功' : '新增成功')
      showModal.value = false
      loadData()
    } else {
      message.error(res.msg || '操作失败')
    }
  } catch (e: any) {
    message.error(e?.response?.data?.detail || '操作失败')
  } finally {
    saving.value = false
  }
}

async function handleDelete(row: any) {
  try {
    const res: any = await request.delete({ url: `/api/admin/design-options/${row.option_id}` }, { isTransformResponse: false })
    if (res.code === 200) { message.success('删除成功'); loadData() }
  } catch { message.error('删除失败') }
}

onMounted(loadData)
</script>
