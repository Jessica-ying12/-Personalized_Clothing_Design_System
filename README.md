# Personalized Clothing Design System · 个性化服装设计系统

> 毕业论文项目：基于 AI 的个性化服装设计平台，支持 AI 生成设计、虚拟试穿与在线定制。

## 项目简介

一个面向个性化服装定制的完整系统，用户可以通过 AI 生成服装设计灵感、上传个人照片进行**虚拟试穿**，并在线定制下单。项目覆盖移动端、管理后台与后端服务三个端，是一个完整的前后端分离全栈项目。

## 系统架构

```
个性化服装设计系统/
├── Personalized_Clothing_Design_System-app-flutter/   # Flutter 移动端 App
├── pcds-admin/                                         # Vue 3 管理后台
└── pcds-backend/                                       # FastAPI 后端服务
```

## 技术栈

| 端 | 技术栈 |
|----|--------|
| **移动端** | Flutter + Dart |
| **管理后台** | Vue 3 + Vite + TypeScript + Tailwind CSS |
| **后端** | FastAPI + SQLAlchemy (async) + MySQL + Redis |
| **认证** | JWT + bcrypt |
| **AI 能力** | Gemini AI（提示词优化）、Pollinations AI（图片生成）、IDM-VTON（虚拟试穿）|

## 核心功能

- **AI 服装设计**：通过大模型生成服装设计灵感与提示词优化
- **虚拟试穿**：上传照片，基于 IDM-VTON 实现虚拟试衣
- **在线定制**：个性化服装定制与下单流程
- **管理后台**：完整的订单、用户、内容管理
- **用户认证**：JWT 认证 + 密码哈希

## 快速开始

### 后端服务

```bash
cd pcds-backend/backend
pip install -r requirements.txt
uvicorn main:app --reload
```

### 管理后台

```bash
cd pcds-admin
pnpm install
pnpm dev
```

### 移动端 App

```bash
cd Personalized_Clothing_Design_System-app-flutter
flutter pub get
flutter run
```

## 技术栈关键词

`Flutter` · `FastAPI` · `Vue 3` · `MySQL` · `Redis` · `JWT` · `AI 图片生成` · `虚拟试穿`

---

_毕业设计项目，完整展示了一个 AI 驱动的个性化服装定制系统的全栈实现。_