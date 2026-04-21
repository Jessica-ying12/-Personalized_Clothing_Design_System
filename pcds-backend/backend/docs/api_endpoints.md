# 个性化服装设计系统 API 说明

## 服务信息

- 基础路径：`http://localhost:9099/dev-api`
- API 文档：`http://localhost:9099/dev-api/docs`
- 认证方式：`Authorization: Bearer <JWT Token>`

## 模块列表

| 模块 | 前缀 | 说明 |
|------|------|------|
| `auth` | `/api/auth` | 注册、登录、OTP、修改密码 |
| `profile` | `/api/profile` | 用户信息、统计、注销 |
| `design-options` | `/api/design-options` | 设计选项配置 |
| `flat-design` | `/api/flat-design` | 平面图生成与管理 |
| `3d-design` | `/api/3d-design` | 立体图生成与管理 |

---

## /api/auth

### POST /api/auth/register
```json
{ "email": "user@example.com", "password": "xxx", "nickname": "昵称" }
```
返回：`{ "code": 200, "data": { "token": "...", "user_id": 1, "email": "...", "nickname": "...", "avatar_url": "" } }`

### POST /api/auth/login
```json
{ "email": "user@example.com", "password": "xxx" }
```
返回同上。

### POST /api/auth/send-otp
```json
{ "email": "user@example.com" }
```
发送6位数字验证码（开发模式打印到后端日志）。

### POST /api/auth/verify-otp
```json
{ "email": "user@example.com", "code": "123456" }
```
验证通过后自动登录/注册，返回 token。

### POST /api/auth/logout
Header: `Authorization: Bearer <token>`

### POST /api/auth/change-password
Header: `Authorization: Bearer <token>`
```json
{ "old_password": "旧密码", "new_password": "新密码" }
```

---

## /api/profile

### GET /api/profile/me
Header: `Authorization: Bearer <token>`
返回：`{ "code": 200, "data": { "user_id": 1, "email": "...", "nickname": "...", "avatar_url": "..." } }`

### PUT /api/profile/update
Header: `Authorization: Bearer <token>`
```json
{ "nickname": "新昵称", "avatar_url": "https://..." }
```

### DELETE /api/profile/delete
Header: `Authorization: Bearer <token>`
软删除账号（设置 deleted_at）。

### GET /api/profile/stats
Header: `Authorization: Bearer <token>`
返回：
```json
{
  "code": 200,
  "data": {
    "flat_total": 10,
    "flat_saved": 8,
    "design_3d_total": 5,
    "design_3d_saved": 4
  }
}
```

---

## /api/design-options

### GET /api/design-options/list?category=clothing_type
不传 category 返回全部选项。

category 枚举：`clothing_type` | `pattern` | `material` | `style` | `audience` | `ai_model` | `body_type` | `skin_tone` | `gender` | `background` | `color`

返回：`{ "code": 200, "data": [ { "id": "ct_tshirt", "category": "clothing_type", "name": "T恤", "name_en": "T-Shirt", "parent_id": "ct_top", "sort_order": 11 } ] }`

### GET /api/design-options/category/{category}
按类别获取，等同于 list?category=xxx。

### GET /api/design-options/children/{parent_id}
获取某选项的子选项，如 `children/ct_top` 返回所有上装子类。

---

## /api/flat-design

### POST /api/flat-design/generate
Header: `Authorization: Bearer <token>`
```json
{
  "clothing_type_code": "ct_tshirt",
  "pattern_code": "p_solid",
  "material_code": "m_cotton",
  "style_code": "s_casual",
  "audience_code": "a_men",
  "ai_model_code": "ai_standard",
  "color_code": "col_white"
}
```
返回 200：`{ "code": 200, "data": <flat_design> }`

### POST /api/flat-design/generate-random
Header: `Authorization: Bearer <token>`
随机选择所有必选项并生成。
返回：`{ "code": 200, "data": { "model": <flat_design>, "clothing_type_code": "...", ... } }`

### POST /api/flat-design/regenerate/{design_id}
Header: `Authorization: Bearer <token>`
重新生成，无次数限制（前端控制最多2次）。

### GET /api/flat-design/list?page=1&page_size=20
Header: `Authorization: Bearer <token>`
返回：`{ "code": 200, "data": { "data": [...], "total": n, "page": 1, "page_size": 20 } }`

### GET /api/flat-design/history?page=1&page_size=20
同 list，返回所有记录（含已删除）。

### GET /api/flat-design/detail/{design_id}
Header: `Authorization: Bearer <token>`

### DELETE /api/flat-design/remove/{design_id}
Header: `Authorization: Bearer <token>`
物理删除记录。

### POST /api/flat-design/save/{design_id}
Header: `Authorization: Bearer <token>`
标记 is_saved=1。

### POST /api/flat-design/batch-remove
Header: `Authorization: Bearer <token>`
```json
{ "ids": ["1", "2", "3"] }
```

---

## /api/3d-design

### POST /api/3d-design/generate
Header: `Authorization: Bearer <token>`
```json
{
  "flat_design_id": "123",
  "body_type_code": "bt_standard",
  "skin_tone_code": "sk_natural",
  "gender_code": "g_female",
  "background_code": "bg_white",
  "ai_model_code": "ai_standard"
}
```
后端内部调用 IDM-VTON 虚拟试穿（失败时降级为 Pollinations AI）。

### POST /api/3d-design/regenerate/{design_id}
Header: `Authorization: Bearer <token>`

### POST /api/3d-design/change-background
Header: `Authorization: Bearer <token>`
```json
{ "design_id": "123", "background_code": "bg_city" }
```

### GET /api/3d-design/list?page=1&page_size=20
### GET /api/3d-design/history?page=1&page_size=20
### GET /api/3d-design/detail/{design_id}
### DELETE /api/3d-design/remove/{design_id}
### POST /api/3d-design/save/{design_id}
### POST /api/3d-design/batch-remove

---

## 错误返回格式

```json
{ "detail": "错误描述" }
```

典型状态码：`400` | `401` | `404` | `422` | `500`

## 安全基线

- 所有需用户上下文的接口必须携带 `Authorization: Bearer <token>`
- 所有接口执行 user_id 边界校验，不允许跨用户操作
