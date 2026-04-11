# 快速开始指南

## 📋 前置要求

### 必需软件
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode（用于移动端开发）
- VS Code 或 Android Studio（推荐）

### 检查环境
```bash
flutter doctor
```

## 🚀 安装步骤

### 1. 克隆项目
```bash
cd Personalized_Clothing_Design_System-app-flutter
```

### 2. 安装依赖
```bash
flutter pub get
```

### 3. 配置环境变量

编辑环境配置文件：

**开发环境** (`.env.dev`)
```env
API_BASE_URL=https://your-dev-project.supabase.co/functions/v1
SUPABASE_URL=https://your-dev-project.supabase.co
SUPABASE_ANON_KEY=your-dev-anon-key
```

**预览环境** (`.env.preview`)
```env
API_BASE_URL=https://your-preview-project.supabase.co/functions/v1
SUPABASE_URL=https://your-preview-project.supabase.co
SUPABASE_ANON_KEY=your-preview-anon-key
```

**生产环境** (`.env.prod`)
```env
API_BASE_URL=https://your-prod-project.supabase.co/functions/v1
SUPABASE_URL=https://your-prod-project.supabase.co
SUPABASE_ANON_KEY=your-prod-anon-key
```

### 4. 运行应用

**开发环境**
```bash
flutter run --dart-define=FLAVOR=dev
```

**预览环境**
```bash
flutter run --dart-define=FLAVOR=preview
```

**生产环境**
```bash
flutter run --dart-define=FLAVOR=prod
```

## 📱 功能测试流程

### 1. 用户注册与登录
1. 启动应用，进入登录页面
2. 点击"注册"切换到注册表单
3. 输入邮箱、密码、昵称
4. 点击"注册"按钮
5. 注册成功后自动登录并跳转到主页

### 2. 生成平面图
1. 在主页（定制标签）
2. 依次选择：
   - 版型（如：衣服）
   - 花纹（如：条纹）
   - 材质（如：棉）
   - 风格（如：休闲）
   - 受众人群（如：青年）
   - 模型（如：Stable Diffusion）
3. 如果有数值参数，可以调整
4. 点击"立即生成"
5. 等待生成完成（会显示加载状态）
6. 查看生成的平面图

### 3. 生成立体图
1. 在平面图生成完成后，点击"生成立体图"
2. 依次选择：
   - 身体三维（如：标准体型）
   - 肤色（如：自然肤色）
   - 性别（如：男性）
   - 模型（如：3D Model）
   - 背景（如：纯色背景）
3. 点击"立即生成"
4. 等待生成完成
5. 查看生成的立体图
6. 可以：
   - 点击"更换背景"切换背景
   - 点击"切换视图"查看平面图
   - 点击"重新生成"重新生成立体图

### 4. 管理设计
1. 切换到"仓库"标签
2. 查看所有保存的设计
3. 点击设计查看大图
4. 可以：
   - 下载图片
   - 重新生成
   - 从平面图生成立体图
   - 删除设计

### 5. 查看历史记录
1. 切换到"我的"标签
2. 点击"历史生成记录"
3. 查看所有历史记录（包括已删除的）
4. 可以：
   - 保存到仓库
   - 删除记录

## 🔧 常见问题

### 1. 依赖安装失败
```bash
# 清理缓存
flutter clean

# 重新安装
flutter pub get
```

### 2. 编译错误
```bash
# 检查 Flutter 版本
flutter --version

# 升级 Flutter
flutter upgrade

# 重新编译
flutter run
```

### 3. API 调用失败
- 检查 `.env.*` 文件配置是否正确
- 检查网络连接
- 检查后端服务是否正常运行
- 查看控制台日志获取详细错误信息

### 4. 图片加载失败
- 检查图片 URL 是否有效
- 检查网络权限配置
- 查看控制台错误日志

## 📦 构建发布版本

### Android APK
```bash
# Debug 版本
flutter build apk --debug --dart-define=FLAVOR=dev

# Release 版本
flutter build apk --release --dart-define=FLAVOR=prod
```

### Android App Bundle
```bash
flutter build appbundle --release --dart-define=FLAVOR=prod
```

### iOS
```bash
# 确保已配置签名
flutter build ios --release --dart-define=FLAVOR=prod
```

## 🧪 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/pages/login_test.dart

# 生成覆盖率报告
flutter test --coverage
```

## 📝 开发建议

### 1. 代码规范
- 遵循 Dart 官方代码规范
- 使用 `flutter analyze` 检查代码
- 使用 `dart format` 格式化代码

### 2. 状态管理
- 所有页面使用 MVVM 模式
- 使用 Riverpod 管理状态
- 保持状态不可变性

### 3. API 调用
- 所有 API 调用通过 Service 层
- 统一错误处理
- 使用 try-catch 捕获异常

### 4. UI 开发
- 使用设计系统中的颜色、间距、文字样式
- 所有文本使用国际化
- 提供加载和错误状态

## 🔗 相关文档

- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev)
- [Go Router 文档](https://pub.dev/packages/go_router)
- [后端 API 文档](../Personalized_Clothing_Design_System-backend-supabase/docs/api_endpoints.md)

## 📞 技术支持

如有问题，请查看：
1. `FINAL_PROJECT_STATUS.md` - 项目完整状态
2. `COMPLETENESS_CHECK.md` - 功能完整性检查
3. `API_INTEGRATION_GUIDE.md` - API 集成指南
4. 控制台日志 - 查看详细错误信息

---

**祝开发顺利！** 🎉
