# Personalized_Clothing_Design_System-backend API 说明（生产版）

## 函数列表

| 函数名 | 说明 |
|--------|------|
| `auth-api` | 注册、登录、获取个人信息 |
| `profile-api` | 更新昵称/头像、注销账号 |
| `design-options-api` | 获取选项配置（版型/花纹/材质等） |
| `flat-design-api` | 平面图生成、重新生成、列表 |
| `design-3d-api` | 立体图生成、重新生成、切换背景、列表 |
| `storage-api` | 图片上传到 Supabase Storage |

基础路径：`https://<project_ref>.supabase.co/functions/v1/<function-name>`

---

## auth-api

### POST /register
```json
{ "email": "user@example.com", "password": "xxx", "full_name": "昵称" }
```
返回：`user`, `session`

### POST /login
```json
{ "email": "user@example.com", "password": "xxx" }
```
返回：`user`, `session`

### POST /login-magic-link
```json
{ "email": "user@example.com" }
```
发送魔法链接到邮箱，用户点击链接完成登录。
返回：`{ "message": "Check your email for login link" }`

### GET /me
Header: `Authorization: Bearer <token>`
返回：`user`, `profile`

### POST /change-password
Header: `Authorization: Bearer <token>`
```json
{ "new_password": "新密码" }
```
修改当前用户密码（至少6个字符）。
返回：`{ "message": "Password changed successfully" }`

### POST /reset-password
```json
{ "email": "user@example.com" }
```
发送密码重置链接到邮箱。
返回：`{ "message": "Check your email for password reset link" }`

---

## profile-api

### POST /update
Header: `Authorization: Bearer <token>`
```json
{ "full_name": "新昵称", "avatar_url": "https://..." }
```
返回：`data`（更新后的 profile）

### DELETE /account
Header: `Authorization: Bearer <token>`
返回：`{ "message": "Account deleted successfully" }`

### GET /stats
Header: `Authorization: Bearer <token>`
获取用户统计信息（生成数量、保存数量）。
返回：
```json
{
  "data": {
    "flat_total": 10,
    "flat_saved": 8,
    "design_3d_total": 5,
    "design_3d_saved": 4
  }
}
```

---

## design-options-api

### GET /options?category=silhouette
获取某分类的一级选项（不传 category 则返回全部一级）
返回：`{ "data": [...] }`

### GET /options/children?parent_id=xxx
获取某选项的子选项（含 meta 数值参数）
返回：`{ "data": [...] }`

category 枚举：`silhouette` | `pattern` | `material` | `style` | `audience` | `ai_model` | `body_shape` | `skin_color` | `gender` | `background`

---

## flat-design-api

### POST /generate
Header: `Authorization: Bearer <token>`
```json
{
  "silhouette_id": "uuid",
  "pattern_id": "uuid",
  "material_id": "uuid",
  "style_id": "uuid",
  "audience_id": "uuid",
  "ai_model_id": "uuid",
  "params": { "chest": 90, "length": 65 },
  "auto_save": true
}
```
`auto_save` 可选，默认 `true`。设为 `false` 时生成的设计不会自动保存到仓库。
返回 201：`{ "data": <flat_design> }`

### POST /generate-random
Header: `Authorization: Bearer <token>`
```json
{}
```
随机选择所有必选项（版型/花纹/材质/风格/受众/模型）并生成平面图。
返回 201：`{ "data": <flat_design> }`

### POST /regenerate
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "uuid" }
```
最多重新生成 2 次，超出返回 422。
返回：`{ "data": <flat_design> }`

### GET /list?page=1&page_size=20
Header: `Authorization: Bearer <token>`
返回：`{ "data": [...], "total": n, "page": 1, "page_size": 20 }`
仅返回 `is_saved=true` 的记录（仓库展示用）

### GET /history?page=1&page_size=20
Header: `Authorization: Bearer <token>`
返回：`{ "data": [...], "total": n, "page": 1, "page_size": 20 }`
返回所有记录（包括已从仓库删除的，用于"我的-历史记录"）

### GET /status?design_id=xxx
Header: `Authorization: Bearer <token>`
查询平面图生成状态（用于轮询检查生成是否完成）。
返回：
```json
{
  "design_id": "uuid",
  "status": "pending|processing|done|failed",
  "image_url": "https://...",
  "error_msg": "错误信息（如果失败）",
  "regen_count": 0
}
```

### GET /detail?design_id=xxx
Header: `Authorization: Bearer <token>`
返回：`{ "data": <flat_design> }`

### DELETE /remove
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "uuid" }
```
从仓库软删除（`is_saved=false`），不删除数据库记录。

### POST /save
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "uuid" }
```
保存到仓库（`is_saved=true`），用于将历史记录中的设计重新添加到仓库。
返回：`{ "message": "Saved to warehouse" }`

---

## design-3d-api

### POST /generate
Header: `Authorization: Bearer <token>`
```json
{
  "flat_design_id": "uuid",
  "body_shape_id": "uuid",
  "skin_color_id": "uuid",
  "gender_id": "uuid",
  "ai_model_id": "uuid",
  "background_id": "uuid",
  "auto_save": true
}
```
`auto_save` 可选，默认 `true`。设为 `false` 时生成的设计不会自动保存到仓库。
返回 201：`{ "data": <design_3d> }`

### POST /regenerate
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "uuid" }
```
最多重新生成 1 次，超出返回 422。

### POST /background
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "uuid", "background_id": "uuid" }
```
切换背景并触发重新生成。

### GET /list?page=1&page_size=20
Header: `Authorization: Bearer <token>`
返回：`{ "data": [...], "total": n, "page": 1, "page_size": 20 }`
仅返回 `is_saved=true` 的记录（仓库展示用）

### GET /history?page=1&page_size=20
Header: `Authorization: Bearer <token>`
返回：`{ "data": [...], "total": n, "page": 1, "page_size": 20 }`
返回所有记录（包括已从仓库删除的，用于"我的-历史记录"）

### GET /status?design_id=xxx
Header: `Authorization: Bearer <token>`
查询立体图生成状态（用于轮询检查生成是否完成）。
返回：
```json
{
  "design_id": "uuid",
  "status": "pending|processing|done|failed",
  "image_url": "https://...",
  "error_msg": "错误信息（如果失败）",
  "regen_count": 0
}
```

### GET /detail?design_id=xxx
Header: `Authorization: Bearer <token>`
返回：`{ "data": <design_3d> }`

### DELETE /remove
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "uuid" }
```
从仓库软删除。

### POST /save
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "uuid" }
```
保存到仓库（`is_saved=true`），用于将历史记录中的设计重新添加到仓库。
返回：`{ "message": "Saved to warehouse" }`

---

## storage-api

### POST /upload
Header: `Authorization: Bearer <token>`
Content-Type: `multipart/form-data`

上传图片文件到 Supabase Storage，返回公开访问 URL。

```
file: <binary>
folder: "flat" | "3d" (可选，默认 "flat")
```

返回：
```json
{
  "url": "https://<project_ref>.supabase.co/storage/v1/object/public/designs/flat/xxx.png",
  "path": "flat/xxx.png"
}
```

### GET /download?path=xxx
Header: `Authorization: Bearer <token>`

生成带签名的临时下载链接（1小时有效）。

返回：
```json
{
  "url": "https://...",
  "expires_at": "2026-04-05T12:00:00Z"
}
```

---

## 错误返回格式

```json
{ "error": "描述", "detail": "可选详情" }
```

典型状态码：`400` | `401` | `404` | `405` | `422` | `500`

## 全业务函数安全基线

- 所有需用户上下文的接口必须校验 `Authorization: Bearer <token>`
- 所有接口必须执行资源级权限校验（user_id 边界）
- 所有接口返回统一 JSON 错误结构
