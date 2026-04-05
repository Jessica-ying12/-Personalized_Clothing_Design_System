# Personalized_Clothing_Design_System-backend API 说明（生产版）

## 函数

- `auth-api`

说明：当前仅列出已上线函数；后续新增函数必须遵循“统一鉴权、统一授权、统一错误模型”的安全基线。

## 基础路径

- `https://<project_ref>.supabase.co/functions/v1/auth-api`

## 1) 注册

- 方法：`POST`
- 路径：`/register`
- 请求体：

```json
{
  "email": "user@example.com",
  "password": "your-password",
  "full_name": "User Name",
  "avatar_url": "https://example.com/avatar.png"
}
```

- 成功：返回 `user`、`session`（若需邮箱确认，session 可能为 null）

## 2) 登录

- 方法：`POST`
- 路径：`/login`
- 请求体：

```json
{
  "email": "user@example.com",
  "password": "your-password"
}
```

- 成功：返回 `user`、`session`

## 3) 获取个人信息

- 方法：`GET`
- 路径：`/me`
- 鉴权：`Authorization: Bearer <access_token>`
- 成功：返回 `user` 与 `profile`

## 错误返回

- 响应格式统一为 JSON
- 典型状态码：`400`、`401`、`404`、`500`

## 全业务函数安全基线

- 所有需用户上下文的接口必须校验 `Authorization: Bearer <access_token>`
- 所有接口必须执行资源级权限校验（用户/租户边界），禁止仅依赖前端控制
- 所有接口必须返回统一 JSON 错误结构，避免泄露内部实现细节
