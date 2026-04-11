# 快速开始指南

## 前置要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Git

## 安装步骤

### 1. 克隆项目

```bash
cd Personalized_Clothing_Design_System-app-flutter
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 配置 Supabase URL

编辑 `lib/core/config/app_config.dart`：

```dart
abstract class AppConfig {
  // 替换为你的 Supabase 项目 URL
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';
  static const String apiBaseUrl = '$supabaseUrl/functions/v1';
  
  // ... 其他配置
}
```

### 4. 运行项目

```bash
# 开发环境
flutter run

# 或指定设备
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

## 项目结构

```
lib/
├── app/                    # 应用配置
│   ├── router/            # 路由管理
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   └── theme/             # 主题系统
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       ├── app_text_styles.dart
│       └── app_theme.dart
├── core/                   # 核心层
│   ├── api/               # API 客户端
│   │   ├── api_client.dart
│   │   └── interceptors/
│   ├── config/            # 配置
│   │   └── app_config.dart
│   ├── models/            # 数据模型
│   │   ├── user_model.dart
│   │   ├── design_option_model.dart
│   │   ├── flat_design_model.dart
│   │   └── design_3d_model.dart
│   ├── providers/         # Riverpod Provider
│   │   └── service_providers.dart
│   ├── services/          # API Service
│   │   ├── auth_service.dart
│   │   ├── profile_service.dart
│   │   ├── design_options_service.dart
│   │   ├── flat_design_service.dart
│   │   └── design_3d_service.dart
│   └── storage/           # 安全存储
│       └── secure_storage.dart
├── pages/                  # 页面
│   ├── login/             # 登录页
│   ├── main/              # 主页
│   ├── design_flat/       # 平面图生成
│   ├── design_3d/         # 立体图生成
│   ├── gallery/           # 仓库
│   └── profile/           # 我的
└── shared/                 # 共享资源
    ├── utils/             # 工具函数
    │   └── download_helper.dart
    └── widgets/           # 共享组件
        ├── feedback/
        │   ├── empty_state.dart
        │   └── error_message.dart
        └── loading/
            └── loading_overlay.dart
```

## 功能使用

### 1. 登录/注册

- 打开应用，默认显示登录页面
- 输入邮箱和密码
- 点击"登录"或切换到"注册"
- 登录成功后自动跳转到主页面

### 2. 平面图生成

1. 在主页面点击"定制" Tab
2. 点击左侧选项（版型、花纹、材质等）
3. 在右侧面板选择具体选项
4. 所有必选项选择完成后，点击"立即生成"
5. 等待生成完成，查看结果
6. 可以点击"重新生成"或"生成立体图"

### 3. 立体图生成

1. 从平面图生成页面点击"生成立体图"
2. 选择身体三维、肤色、性别、模型、背景
3. 点击"立即生成"
4. 等待生成完成
5. 可以切换背景、切换视图、重新生成

### 4. 仓库管理

1. 在主页面点击"仓库" Tab
2. 切换"平面展示"或"立体展示" Tab
3. 点击图片查看详情
4. 可以下载、重新生成、删除设计

### 5. 用户中心

1. 在主页面点击"我的" Tab
2. 查看用户信息
3. 可以退出登录或注销账号

## 常见问题

### Q: 运行时提示找不到包？

A: 运行 `flutter pub get` 安装依赖

### Q: 登录失败？

A: 检查 Supabase URL 配置是否正确，确保后端服务正常运行

### Q: 图片无法显示？

A: 检查网络连接，确保图片 URL 可访问

### Q: 下载失败？

A: 检查存储权限，Android 需要在 AndroidManifest.xml 中添加权限

### Q: 生成一直在加载？

A: 检查后端 API 是否正常，查看控制台错误日志

## 开发建议

### 1. 代码规范

- 使用 `flutter analyze` 检查代码
- 遵循 Flutter 官方代码规范
- 使用 const 构造函数
- 添加适当的注释

### 2. 状态管理

- 使用 Riverpod 管理状态
- 遵循 MVVM 架构
- State 不可变，使用 copyWith 更新

### 3. 错误处理

- 所有 API 调用使用 try-catch
- 显示友好的错误提示
- 记录错误日志

### 4. 性能优化

- 使用 ListView.builder 懒加载
- 避免不必要的 rebuild
- 使用 const 构造函数
- 图片缓存

## 调试技巧

### 1. 查看日志

```bash
flutter logs
```

### 2. 热重载

按 `r` 键进行热重载，按 `R` 键进行热重启

### 3. 调试模式

在 VS Code 中按 F5 启动调试模式

### 4. 性能分析

```bash
flutter run --profile
```

## 构建发布版本

### Android

```bash
flutter build apk --release
# 或
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 相关文档

- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - 项目结构说明
- [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) - API 集成指南
- [DEPENDENCIES.md](DEPENDENCIES.md) - 依赖清单
- [NEXT_STEPS.md](NEXT_STEPS.md) - 下一步开发指南
- [FINAL_STATUS.md](FINAL_STATUS.md) - 项目状态报告

## 获取帮助

如果遇到问题：

1. 查看相关文档
2. 检查控制台错误日志
3. 运行 `flutter doctor` 检查环境
4. 查看 Flutter 官方文档

## 贡献指南

1. Fork 项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建 Pull Request

## 许可证

[添加许可证信息]
