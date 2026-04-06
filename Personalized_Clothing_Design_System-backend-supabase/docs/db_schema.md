# Personalized_Clothing_Design_System-backend 数据库设计（生产版）

## 表清单

| 表名 | 说明 |
|------|------|
| `public.profiles` | 用户基本信息（已有） |
| `public.design_options` | 选项配置（版型/花纹/材质/风格/受众/模型等） |
| `public.flat_designs` | 平面图生成记录 |
| `public.designs_3d` | 立体图生成记录 |

---

## profiles

- `id uuid`：主键，关联 `auth.users.id`
- `full_name text`：用户昵称
- `avatar_url text`：头像地址
- `created_at timestamptz`
- `updated_at timestamptz`

RLS：仅 `auth.uid() = id` 可读写

---

## design_options

选项配置表，支持两级树形结构（一级分类 → 二级具体选项）。

- `id uuid`：主键
- `category text`：分类标识，枚举值：
  - `silhouette`（版型）
  - `pattern`（花纹）
  - `material`（材质）
  - `style`（风格）
  - `audience`（受众人群）
  - `ai_model`（AI生图模型）
  - `body_shape`（身体三维）
  - `skin_color`（肤色）
  - `gender`（性别）
  - `background`（背景）
- `parent_id uuid`：父选项 id，null 表示一级
- `name text`：中文名称
- `name_en text`：英文名称
- `sort_order int`：排序
- `meta jsonb`：扩展信息，二级选项存数值参数范围，格式：
  ```json
  {"params":[{"key":"chest","label":"胸围(cm)","min":60,"max":130,"default":90}]}
  ```
- `is_active boolean`：是否启用
- `created_at timestamptz`

RLS：公开只读（允许匿名读取）

---

## flat_designs

平面图生成记录，每条记录对应一次生成任务。

- `id uuid`：主键
- `user_id uuid`：关联 `auth.users.id`
- `silhouette_id uuid`：版型选项 id（二级）
- `pattern_id uuid`：花纹选项 id
- `material_id uuid`：材质选项 id
- `style_id uuid`：风格选项 id
- `audience_id uuid`：受众选项 id
- `ai_model_id uuid`：AI模型选项 id
- `params jsonb`：数值参数快照，如 `{"chest":90,"waist":70,"length":65}`
- `image_url text`：生成图片 URL
- `status text`：`pending` | `processing` | `done` | `failed`
- `error_msg text`：失败原因
- `regen_count int`：已重新生成次数（上限 2）
- `is_saved boolean`：是否在仓库中显示（软删除）
- `created_at / updated_at timestamptz`

RLS：仅 `auth.uid() = user_id` 可读写

---

## designs_3d

立体图生成记录，关联平面图。

- `id uuid`：主键
- `user_id uuid`：关联 `auth.users.id`
- `flat_design_id uuid`：关联 `flat_designs.id`
- `body_shape_id uuid`：身体三维选项 id
- `skin_color_id uuid`：肤色选项 id
- `gender_id uuid`：性别选项 id
- `ai_model_id uuid`：AI模型选项 id
- `background_id uuid`：背景选项 id（可切换）
- `image_url text`：生成图片 URL
- `status text`：`pending` | `processing` | `done` | `failed`
- `error_msg text`：失败原因
- `regen_count int`：已重新生成次数（上限 1）
- `is_saved boolean`：是否在仓库中显示
- `created_at / updated_at timestamptz`

RLS：仅 `auth.uid() = user_id` 可读写

---

## 自动化机制

- `on_auth_user_created`：注册后自动创建 profiles
- `on_profiles_updated`：更新 profile 时刷新 `updated_at`
- `on_flat_designs_updated`：更新 flat_designs 时刷新 `updated_at`
- `on_designs_3d_updated`：更新 designs_3d 时刷新 `updated_at`
- `increment_flat_regen_count(design_id)`：原子递增平面图重生成计数
- `increment_3d_regen_count(design_id)`：原子递增立体图重生成计数

---

## 迁移文件

- `202603110001_init.sql`：profiles 初始化
- `202604050001_business_tables.sql`：业务表 + 种子数据
- `202604050002_regen_rpc.sql`：重生成计数 RPC
- `202604050003_storage_bucket.sql`：Storage Bucket 配置

## Storage Bucket

- `designs`：存储平面图和立体图
  - 公开访问（public）
  - 文件大小限制：10MB
  - 允许的 MIME 类型：`image/png`, `image/jpeg`, `image/jpg`, `image/webp`
  - RLS 策略：
    - 用户只能上传自己的文件
    - 所有人可以读取公开文件
    - 用户可以删除自己的文件

## 全业务安全基线

- 新增业务表必须同批提交 RLS 策略与必要索引，默认最小权限拒绝
- 迁移发布仅通过新增迁移文件执行，禁止修改历史迁移
- 生产环境保持 `ENABLE_DB_RESET=0`
