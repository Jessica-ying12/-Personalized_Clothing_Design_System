# 快速运行指南

## 🚀 5 分钟快速启动

### 前置条件
- ✅ Flutter SDK >= 3.0.0
- ✅ Dart SDK >= 3.0.0
- ✅ Android Studio / Xcode
- ✅ 已连接的设备或模拟器

---

## 📝 步骤 1：安装依赖

```bash
cd Personalized_Clothing_Design_System-app-flutter
flutter pub get
```

**预期输出**：
```
Got dependencies!
```

---

## ⚙️ 步骤 2：配置后端 URL

编辑 `lib/core/config/app_config.dart`：

```dart
abstract class AppConfig {
  // 替换为你的 Supabase 项目 URL
  static const String supabaseUrl = 'https://your-project-ref.supabase.co';
  static const String apiBaseUrl = '$supabaseUrl/functions/v1';
  
  // ... 其他配置
}
```

**重要**：如果没有后端，可以先使用测试 URL 查看 UI。

---

## 🏃 步骤 3：运行应用

### 方式 1：使用命令行（推荐）

```bash
# 开发环境
flutter run --dart-define=FLAVOR=dev

# 或者直接运行
flutter run
```

### 方式 2：使用 IDE

1. 打开 `lib/main.dart`
2. 点击 Run 按钮（绿色三角形）
3. 选择目标设备

---

## 📱 步骤 4：测试功能

### 4.1 注册账号
1. 启动应用后会看到启动页
2. 自动跳转到登录页
3. 点击"注册"标签
4. 输入邮箱和密码
5. 点击"注册"按钮

### 4.2 登录
1. 输入注册的邮箱和密码
2. 点击"登录"按钮
3. 成功后跳转到主页

### 4.3 生成平面图
1. 在主页点击"平面图生成"标签
2. 选择 6 个必选参数
3. 点击"立即生成"或"随机生成"
4. 等待生成完成

### 4.4 生成立体图
1. 在平面图生成完成后
2. 点击"生成立体图"按钮
3. 选择 5 个必选参数
4. 点击"立即生成"
5. 等待生成完成

### 4.5 查看仓库
1. 点击底部导航栏的"仓库"标签
2. 查看已保存的设计
3. 点击图片查看详情
4. 可以下载或删除设计

---

## 🔧 常见问题

### Q1: 依赖安装失败
```bash
# 清理缓存后重试
flutter clean
flutter pub get
```

### Q2: 编译错误
```bash
# 重新生成代码
flutter pub run build_runner build --delete-conflicting-outputs
```

### Q3: 无法连接后端
- 检查 `app_config.dart` 中的 URL 是否正确
- 确保后端服务正在运行
- 检查网络连接

### Q4: Token 存储失败
- 确保已安装 `flutter_secure_storage` 依赖
- Android：检查权限配置
- iOS：检查 Keychain 权限

### Q5: 图片下载失败
- Android：检查存储权限
- iOS：检查相册权限
- 确保网络连接正常

---

## 📦 构建发布版本

### Android APK
```bash
flutter build apk --release --dart-define=FLAVOR=prod
```

输出位置：`build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release --dart-define=FLAVOR=prod
```

输出位置：`build/app/outputs/bundle/release/app-release.aab`

### iOS
```bash
flutter build ios --release --dart-define=FLAVOR=prod
```

---

## 🎯 功能清单

### ✅ 已实现功能
- [x] 用户注册/登录
- [x] 自动登录
- [x] 平面图生成（6 个参数）
- [x] 随机生成平面图
- [x] 平面图重新生成（最多 2 次）
- [x] 立体图生成（5 个参数）
- [x] 立体图重新生成（最多 1 次）
- [x] 更换背景
- [x] 视图切换
- [x] 设计仓库管理
- [x] 历史记录查看
- [x] 图片下载
- [x] 图片缩放查看
- [x] 个人资料编辑
- [x] 语言切换（中文/英文）
- [x] 缓存管理
- [x] 退出登录
- [x] 注销账号

### 🔜 预留功能
- [ ] 图片上传（相机/相册）
- [ ] 图片分享
- [ ] 推送通知
- [ ] 深色模式
- [ ] 搜索和筛选
- [ ] 收藏功能

---

## 📚 相关文档

- [README.md](README.md) - 项目概览
- [GETTING_STARTED.md](GETTING_STARTED.md) - 详细安装指南
- [DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md) - 开发规范
- [API_INTEGRATION_GUIDE.md](API_INTEGRATION_GUIDE.md) - API 集成
- [FINAL_COMPLETE_PROJECT_REPORT.md](FINAL_COMPLETE_PROJECT_REPORT.md) - 完整报告

---

## 💡 提示

1. **首次运行**：首次运行可能需要下载依赖，请耐心等待
2. **热重载**：修改代码后按 `r` 键热重载，按 `R` 键热重启
3. **调试模式**：开发时使用 Debug 模式，发布时使用 Release 模式
4. **日志查看**：使用 `flutter logs` 查看应用日志
5. **性能分析**：使用 `flutter run --profile` 进行性能分析

---

## 🎉 开始使用

现在你可以开始使用这个完整的 Flutter 应用了！

如有问题，请查看详细文档或联系技术支持。

**祝你使用愉快！** 🚀
