# 个性化服装设计系统 数据库设计

## 数据库

- 类型：MySQL 8.0+
- 数据库名：`pcds_db`
- 字符集：`utf8mb4`

## 表清单

| 表名 | 说明 |
|------|------|
| `pcds_user` | 用户信息 |
| `pcds_design_option` | 设计选项配置（版型/花纹/材质等） |
| `pcds_flat_design` | 平面图生成记录 |
| `pcds_3d_design` | 立体图生成记录 |

---

## pcds_user

| 字段 | 类型 | 说明 |
|------|------|------|
| `user_id` | BIGINT PK AUTO_INCREMENT | 用户ID |
| `email` | VARCHAR(100) UNIQUE NOT NULL | 邮箱（登录账号） |
| `password_hash` | VARCHAR(255) NOT NULL | bcrypt 密码哈希 |
| `nickname` | VARCHAR(50) | 昵称 |
| `avatar_url` | VARCHAR(500) | 头像URL |
| `status` | CHAR(1) DEFAULT '0' | 0正常 1停用 |
| `created_at` | DATETIME | 创建时间 |
| `updated_at` | DATETIME | 更新时间 |
| `deleted_at` | DATETIME NULL | 软删除时间 |

---

## pcds_design_option

选项配置表，支持两级树形结构（一级分类 → 二级具体选项）。

| 字段 | 类型 | 说明 |
|------|------|------|
| `option_id` | BIGINT PK AUTO_INCREMENT | 选项ID |
| `category` | VARCHAR(50) NOT NULL | 分类标识 |
| `option_code` | VARCHAR(50) NOT NULL | 选项代码（唯一键） |
| `name_zh` | VARCHAR(100) NOT NULL | 中文名称 |
| `name_en` | VARCHAR(100) NOT NULL | 英文名称 |
| `parent_id` | BIGINT NULL | 父选项ID，null 表示一级 |
| `sort_order` | INT DEFAULT 0 | 排序 |
| `status` | CHAR(1) DEFAULT '0' | 0启用 1停用 |
| `created_at` | DATETIME | 创建时间 |

category 枚举：
- `clothing_type`（版型）
- `pattern`（花纹）
- `material`（材质）
- `style`（风格）
- `audience`（受众人群）
- `ai_model`（AI生图模型）
- `body_type`（身体三维）
- `skin_tone`（肤色）
- `gender`（性别）
- `background`（背景）
- `color`（颜色）

唯一约束：`(category, option_code)`

---

## pcds_flat_design

平面图生成记录，每条记录对应一次生成任务。

| 字段 | 类型 | 说明 |
|------|------|------|
| `design_id` | BIGINT PK AUTO_INCREMENT | 设计ID |
| `user_id` | BIGINT NOT NULL | 用户ID |
| `clothing_type_code` | VARCHAR(50) NOT NULL | 版型代码 |
| `pattern_code` | VARCHAR(50) NOT NULL | 花纹代码 |
| `material_code` | VARCHAR(50) NOT NULL | 材质代码 |
| `style_code` | VARCHAR(50) NOT NULL | 风格代码 |
| `audience_code` | VARCHAR(50) NOT NULL | 受众代码 |
| `color_code` | VARCHAR(50) NULL | 颜色代码（可选） |
| `ai_model_code` | VARCHAR(50) NOT NULL | AI模型代码 |
| `image_url` | VARCHAR(500) NOT NULL | 生成图片URL |
| `prompt` | TEXT NULL | AI提示词 |
| `status` | VARCHAR(20) DEFAULT 'done' | pending/processing/done/failed |
| `is_saved` | TINYINT(1) DEFAULT 1 | 是否保存到仓库 |
| `regen_count` | INT DEFAULT 0 | 重新生成次数 |
| `created_at` | DATETIME | 创建时间 |
| `updated_at` | DATETIME | 更新时间 |

索引：`idx_user_id(user_id)`, `idx_created_at(created_at)`

---

## pcds_3d_design

立体图生成记录，关联平面图。

| 字段 | 类型 | 说明 |
|------|------|------|
| `design_id` | BIGINT PK AUTO_INCREMENT | 设计ID |
| `user_id` | BIGINT NOT NULL | 用户ID |
| `flat_design_id` | BIGINT NOT NULL | 关联平面设计ID |
| `body_type_code` | VARCHAR(50) NOT NULL | 身体三维代码 |
| `skin_tone_code` | VARCHAR(50) NOT NULL | 肤色代码 |
| `gender_code` | VARCHAR(50) NOT NULL | 性别代码 |
| `background_code` | VARCHAR(50) NOT NULL | 背景代码 |
| `ai_model_code` | VARCHAR(50) NOT NULL | AI模型代码 |
| `image_url` | VARCHAR(500) NOT NULL | 生成图片URL |
| `prompt` | TEXT NULL | AI提示词 |
| `status` | VARCHAR(20) DEFAULT 'done' | pending/processing/done/failed |
| `is_saved` | TINYINT(1) DEFAULT 1 | 是否保存到仓库 |
| `regen_count` | INT DEFAULT 0 | 重新生成次数 |
| `created_at` | DATETIME | 创建时间 |
| `updated_at` | DATETIME | 更新时间 |

索引：`idx_user_id(user_id)`, `idx_flat_design_id(flat_design_id)`, `idx_created_at(created_at)`

---

## 自动化机制

- SQLAlchemy `onupdate` 自动刷新 `updated_at`
- 应用启动时 `init_create_table()` 自动建表
- 应用启动时 `init_default_options()` 自动初始化设计选项种子数据

## 安全基线

- 所有查询必须携带 `user_id` 边界条件，禁止跨用户访问
- 密码使用 bcrypt 哈希存储，禁止明文
- 软删除通过 `deleted_at` 字段实现，查询时过滤 `deleted_at IS NULL`
