# 项目依赖清单

## 必需依赖

请在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 状态管理
  flutter_riverpod: ^2.4.9
  
  # 路由
  go_router: ^13.0.0
  
  # 网络请求
  dio: ^5.4.0
  
  # 安全存储
  flutter_secure_storage: ^9.0.0
  
  # 国际化
  flutter_i18n: ^0.35.1
  
  # 文件路径
  path_provider: ^2.1.1
  
  # UI 组件
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

## 依赖说明

### flutter_riverpod
- 用途：状态管理
- 版本：^2.4.9
- 说明：用于管理应用状态，实现 MVVM 架构

### go_router
- 用途：路由管理
- 版本：^13.0.0
- 说明：声明式路由，支持深度链接

### dio
- 用途：HTTP 客户端
- 版本：^5.4.0
- 说明：强大的 HTTP 客户端，支持拦截器、请求取消等

### flutter_secure_storage
- 用途：安全存储
- 版本：^9.0.0
- 说明：安全存储敏感数据（如 Token），使用平台原生加密

### flutter_i18n
- 用途：国际化
- 版本：^0.35.1
- 说明：支持多语言，从 JSON 文件加载翻译

## 安装步骤

1. 将上述依赖添加到 `pubspec.yaml`
2. 运行命令安装依赖：
   ```bash
   flutter pub get
   ```

## 平台特定配置

### Android

在 `android/app/build.gradle` 中确保 minSdkVersion >= 18：

```gradle
android {
    defaultConfig {
        minSdkVersion 18
    }
}
```

### iOS

在 `ios/Podfile` 中确保平台版本 >= 12.0：

```ruby
platform :ios, '12.0'
```

对于 flutter_secure_storage，需要在 `ios/Runner/Info.plist` 中添加：

```xml
<key>NSFaceIDUsageDescription</key>
<string>需要使用 Face ID 来保护您的数据</string>
```

## 可选依赖

根据需要可以添加以下依赖：

### 图片处理
```yaml
cached_network_image: ^3.3.0  # 图片缓存
image_picker: ^1.0.5          # 图片选择
```

### 文件下载
```yaml
path_provider: ^2.1.1         # 获取文件路径
permission_handler: ^11.0.1   # 权限管理
```

### UI 增强
```yaml
shimmer: ^3.0.0               # 骨架屏动画
lottie: ^2.7.0                # Lottie 动画
```

### 工具类
```yaml
intl: ^0.18.1                 # 日期格式化
uuid: ^4.2.1                  # UUID 生成
```

## 验证安装

运行以下命令验证依赖是否正确安装：

```bash
flutter doctor
flutter pub get
flutter analyze
```

如果没有错误，说明依赖安装成功。
