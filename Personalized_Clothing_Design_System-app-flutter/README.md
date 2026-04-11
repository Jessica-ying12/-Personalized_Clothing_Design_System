# 个性化服装设计系统 - Flutter 前端

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Status](https://img.shields.io/badge/status-完成-success.svg)

基于 Flutter 与多模态 AI 的个性化服装设计自动化应用

[功能特性](#-功能特性) • [快速开始](#-快速开始) • [项目结构](#-项目结构) • [技术栈](#-技术栈) • [文档](#-文档)

</div>

---

## 📖 项目简介

这是一个基于 Flutter 开发的个性化服装设计系统前端应用，采用 MVVM 架构模式，集成了完整的后端 API，实现了从用户登录到 AI 设计生成、保存、管理的完整业务流程。

### 核心功能
- 🎨 **AI 平面图生成**：通过选择版型、花纹、材质等参数，AI 自动生成服装平面设计图
- 🎭 **AI 立体图生成**：基于平面图，生成 3D 立体展示效果
- 📦 **设计仓库管理**：保存、查看、下载、删除设计作品
- 📜 **历史记录追踪**：查看所有生成历史，支持恢复已删除设计
- 👤 **用户中心**：个人信息管理、账号设置

## ✨ 功能特性

### 🎯 设计生成
- **平面图生成**
  - 6 个必选参数：版型、花纹、材质、风格、受众人群、AI 模型
  - 支持二级选项展开和数值参数调整
  - 实时生成状态轮询
  - 支持重新生成（最多 2 次）

- **立体图生成**
  - 5 个必选参数：身体三维、肤色、性别、AI 模型、背景
  - 实时生成状态轮询
  - 支持更换背景
  - 支持平面图/立体图视图切换
  - 支持重新生成（最多 1 次）

### 📱 用户体验
- **流畅交互**：响应式 UI，流畅的页面切换
- **实时反馈**：加载状态、错误提示、成功反馈
- **国际化支持**：中文、英文双语切换
- **离线缓存**：Token 安全存储，自动登录

### 🔐 安全性
- JWT Token 认证
- 安全存储（flutter_secure_storage）
- 请求拦截器自动添加认证头
- 统一错误处理

## 🚀 快速开始

### 前置要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode

### 安装步骤

1. **安装依赖**
```bash
flutter pub get
```

2. **配置环境变量**

编辑 `.env.dev` 文件：
```env
API_BASE_URL=https://your-project.supabase.co/functions/v1
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

3. **运行应用**
```bash
# 开发环境
flutter run --dart-define=FLAVOR=dev

# 生产环境
flutter run --dart-define=FLAVOR=prod
```

详细步骤请查看 [快速开始指南](GETTING_STARTED.md)

## 📁 项目结构

```
lib/
├── app/                    # 应用配置
│   ├── router/            # 路由配置
│   └── theme/             # 主题配置
├── core/                  # 核心功能
│   ├── api/              # API 客户端
│   ├── models/           # 数据模型
│   ├── services/         # 服务层
│   └── storage/          # 本地存储
├── pages/                # 页面
│   ├── login/           # 登录页
│   ├── main/            # 主导航页
│   ├── design_flat/     # 平面图生成页
│   ├── design_3d/       # 立体图生成页
│   ├── gallery/         # 仓库页
│   ├── history/         # 历史记录页
│   └── profile/         # 个人中心页
└── shared/              # 共享资源
    ├── utils/          # 工具类
    └── widgets/        # 共享组件
```

## 🛠️ 技术栈

### 核心框架
- **Flutter 3.0+**：跨平台 UI 框架
- **Dart 3.0+**：编程语言

### 状态管理
- **Riverpod**：响应式状态管理
- **MVVM 架构**：Model-View-ViewModel 模式

### 网络请求
- **Dio**：HTTP 客户端
- **flutter_secure_storage**：安全存储

### 路由导航
- **go_router**：声明式路由

### 国际化
- **flutter_i18n**：国际化框架

### UI 组件
- **Material Design**：UI 设计规范
- **自定义设计系统**：统一的颜色、间距、文字样式

## 📚 文档

### 主要文档
- [快速开始指南](GETTING_STARTED.md) - 详细的安装和运行步骤
- [项目完整状态](FINAL_PROJECT_STATUS.md) - 项目完成度和技术细节
- [完整性检查清单](COMPLETENESS_CHECK.md) - 功能完整性验证
- [API 集成指南](API_INTEGRATION_GUIDE.md) - 后端 API 集成说明
- [依赖说明](DEPENDENCIES.md) - 项目依赖详细说明

### 后端文档
- [后端 API 文档](../Personalized_Clothing_Design_System-backend-supabase/docs/api_endpoints.md)

## 🎨 设计系统

### 颜色规范
- **主色调**：#3D7BF5（蓝色）
- **中性色**：灰度色阶（grey50 - grey900）
- **语义色**：成功、警告、错误、信息

### 间距规范
- **xs**: 4px
- **sm**: 8px
- **md**: 16px
- **lg**: 24px
- **xl**: 32px

### 文字样式
- **标题**：titleLg, titleMd, titleSm
- **正文**：bodyLg, bodyMd, bodySm
- **标签**：labelLg, labelMd, labelSm

## 🔄 开发流程

### 1. 创建新页面
```dart
// 1. 创建 State
class NewPageState {
  const NewPageState({this.data});
  final String? data;
  
  NewPageState copyWith({String? data}) {
    return NewPageState(data: data ?? this.data);
  }
}

// 2. 创建 ViewModel
class NewPageViewModel extends Notifier<NewPageState> {
  @override
  NewPageState build() => const NewPageState();
}

// 3. 创建 Page
class NewPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newPageViewModelProvider);
    return Scaffold(/* ... */);
  }
}
```

### 2. 添加 API 服务
```dart
class NewService {
  final ApiClient _apiClient;
  
  NewService(this._apiClient);
  
  Future<Model> getData() async {
    final response = await _apiClient.get('/endpoint');
    return Model.fromJson(response.data);
  }
}
```

### 3. 添加路由
```dart
// route_names.dart
static const newPage = '/new-page';

// app_router.dart
GoRoute(
  path: RouteName.newPage,
  builder: (context, state) => const NewPage(),
),
```

## 🧪 测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/pages/login_test.dart

# 生成覆盖率报告
flutter test --coverage
```

## 📦 构建发布

### Android
```bash
# APK
flutter build apk --release --dart-define=FLAVOR=prod

# App Bundle
flutter build appbundle --release --dart-define=FLAVOR=prod
```

### iOS
```bash
flutter build ios --release --dart-define=FLAVOR=prod
```

## 🤝 贡献指南

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

项目链接: [https://github.com/yourusername/Personalized_Clothing_Design_System-app-flutter](https://github.com/yourusername/Personalized_Clothing_Design_System-app-flutter)

## 🙏 致谢

- [Flutter](https://flutter.dev/) - UI 框架
- [Riverpod](https://riverpod.dev/) - 状态管理
- [Supabase](https://supabase.com/) - 后端服务
- [Material Design](https://material.io/) - 设计规范

---

<div align="center">

**Made with ❤️ using Flutter**

</div>
