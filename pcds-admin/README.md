# 个性化服装设计系统 - 管理台

基于 Vue 3 + TypeScript + Naive UI 的管理后台。

## 技术栈

- Vue 3 + TypeScript
- Vite 构建
- Pinia 状态管理
- Naive UI 组件库
- Tailwind CSS

## 本地启动

```bash
# 安装依赖
yarn install

# 启动开发服务器（端口 5183）
yarn dev
```

## 环境配置

编辑 `.env.development`：

```env
VITE_APP_BASE_URL=http://localhost:9099
VITE_APP_BASE_API=/dev-api
VITE_APP_TITLE=个性化服装设计系统-管理台
```

## 功能模块

- 首页统计（用户数、平面图数、立体图数）
- 用户管理（`/pcds/users`）
- 平面图管理（`/pcds/flat-designs`）
- 立体图管理（`/pcds/3d-designs`）
- 设计选项管理（`/pcds/design-options`）

## 对应后端

后端项目：`pcds-backend/backend/`，启动命令：

```bash
cd pcds-backend/backend
python main.py
```
