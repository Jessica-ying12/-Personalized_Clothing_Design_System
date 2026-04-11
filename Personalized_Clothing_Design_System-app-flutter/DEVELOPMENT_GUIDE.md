# 开发规范指南

## 📋 目录

- [代码规范](#代码规范)
- [架构规范](#架构规范)
- [命名规范](#命名规范)
- [文件组织](#文件组织)
- [最佳实践](#最佳实践)
- [常见问题](#常见问题)

## 代码规范

### Dart 代码风格

遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 官方规范：

```dart
// ✅ 好的示例
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;

  UserProfile copyWith({
    String? id,
    String? name,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// ❌ 不好的示例
class userprofile {
  String? id;
  String? name;
  String? avatar_url;
}
```

### 代码格式化

使用 `dart format` 自动格式化代码：

```bash
# 格式化单个文件
dart format lib/pages/login/login_page.dart

# 格式化整个项目
dart format .
```

### 代码分析

使用 `flutter analyze` 检查代码问题：

```bash
flutter analyze
```

## 架构规范

### MVVM 模式

所有页面必须遵循 MVVM 三文件模式：

```
pages/
└── feature_name/
    ├── feature_name_page.dart       # View 层
    ├── feature_name_state.dart      # Model 层
    └── feature_name_view_model.dart # ViewModel 层
```

#### 1. State（状态模型）

```dart
class FeatureState {
  const FeatureState({
    this.data,
    this.isLoading = false,
    this.errorMessage,
  });

  final DataModel? data;
  final bool isLoading;
  final String? errorMessage;

  FeatureState copyWith({
    DataModel? data,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeatureState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
```

#### 2. ViewModel（业务逻辑）

```dart
class FeatureViewModel extends Notifier<FeatureState> {
  @override
  FeatureState build() {
    // 初始化逻辑
    return const FeatureState();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(serviceProvider);
      final data = await service.getData();
      
      state = state.copyWith(
        isLoading: false,
        data: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final featureViewModelProvider =
    NotifierProvider<FeatureViewModel, FeatureState>(
  FeatureViewModel.new,
);
```

#### 3. Page（UI 视图）

```dart
class FeaturePage extends ConsumerWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureViewModelProvider);
    final viewModel = ref.read(featureViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'feature.title')),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context, state, viewModel),
    );
  }

  Widget _buildContent(
    BuildContext context,
    FeatureState state,
    FeatureViewModel viewModel,
  ) {
    // UI 实现
    return Container();
  }
}
```

## 命名规范

### 文件命名

- 使用 **snake_case**（小写下划线）
- 文件名应该描述其内容

```
✅ user_profile_page.dart
✅ design_flat_view_model.dart
✅ app_colors.dart

❌ UserProfilePage.dart
❌ designFlatViewModel.dart
❌ AppColors.dart
```

### 类命名

- 使用 **PascalCase**（大驼峰）
- 类名应该是名词

```dart
✅ class UserProfile { }
✅ class DesignFlatViewModel { }
✅ class ApiClient { }

❌ class userProfile { }
❌ class design_flat_view_model { }
❌ class apiClient { }
```

### 变量和方法命名

- 使用 **camelCase**（小驼峰）
- 变量名应该是名词
- 方法名应该是动词

```dart
✅ final userName = 'John';
✅ void loadUserData() { }
✅ bool isLoading = false;

❌ final UserName = 'John';
❌ void LoadUserData() { }
❌ bool IsLoading = false;
```

### 常量命名

- 使用 **camelCase**
- 对于编译时常量，可以使用 **lowerCamelCase**

```dart
✅ const apiTimeout = Duration(seconds: 30);
✅ const maxRetryCount = 3;

❌ const API_TIMEOUT = Duration(seconds: 30);
❌ const MAX_RETRY_COUNT = 3;
```

### Provider 命名

- 以 `Provider` 结尾

```dart
✅ final userServiceProvider = Provider<UserService>(...);
✅ final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(...);

❌ final userService = Provider<UserService>(...);
❌ final authViewModel = NotifierProvider<AuthViewModel, AuthState>(...);
```

## 文件组织

### 导入顺序

1. Dart SDK 导入
2. Flutter 导入
3. 第三方包导入
4. 项目内部导入

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 第三方包
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. 项目内部
import '../../core/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../login/login_page.dart';
```

### 目录结构

```
lib/
├── app/                      # 应用级配置
│   ├── router/              # 路由
│   └── theme/               # 主题
├── core/                    # 核心功能
│   ├── api/                # API 客户端
│   ├── config/             # 配置
│   ├── models/             # 数据模型
│   ├── providers/          # Provider 定义
│   ├── services/           # 服务层
│   └── storage/            # 本地存储
├── pages/                   # 页面
│   └── feature_name/       # 功能页面
│       ├── feature_name_page.dart
│       ├── feature_name_state.dart
│       └── feature_name_view_model.dart
└── shared/                  # 共享资源
    ├── utils/              # 工具类
    └── widgets/            # 共享组件
```

## 最佳实践

### 1. 状态管理

#### 使用不可变状态

```dart
// ✅ 好的示例
class UserState {
  const UserState({this.user});
  final User? user;
  
  UserState copyWith({User? user}) {
    return UserState(user: user ?? this.user);
  }
}

// ❌ 不好的示例
class UserState {
  User? user;
  
  void setUser(User user) {
    this.user = user;
  }
}
```

#### 避免在 build 方法中调用异步方法

```dart
// ✅ 好的示例
@override
FeatureState build() {
  // 在 build 中调用同步初始化
  _initialize();
  return const FeatureState();
}

void _initialize() {
  // 异步操作放在单独的方法中
  Future.microtask(() => loadData());
}

// ❌ 不好的示例
@override
FeatureState build() {
  loadData(); // 不要在 build 中直接调用异步方法
  return const FeatureState();
}
```

### 2. API 调用

#### 统一错误处理

```dart
// ✅ 好的示例
Future<void> loadData() async {
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    final data = await service.getData();
    state = state.copyWith(isLoading: false, data: data);
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: e.toString(),
    );
  }
}

// ❌ 不好的示例
Future<void> loadData() async {
  final data = await service.getData(); // 没有错误处理
  state = state.copyWith(data: data);
}
```

#### 使用 Service 层

```dart
// ✅ 好的示例
class UserViewModel extends Notifier<UserState> {
  Future<void> loadUser() async {
    final service = ref.read(userServiceProvider);
    final user = await service.getUser();
    state = state.copyWith(user: user);
  }
}

// ❌ 不好的示例
class UserViewModel extends Notifier<UserState> {
  Future<void> loadUser() async {
    // 直接在 ViewModel 中调用 API
    final response = await http.get(Uri.parse('/api/user'));
    final user = User.fromJson(jsonDecode(response.body));
    state = state.copyWith(user: user);
  }
}
```

### 3. UI 开发

#### 使用设计系统

```dart
// ✅ 好的示例
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
  ),
  child: Text(
    'Hello',
    style: AppTextStyles.bodyMd.copyWith(
      color: AppColors.grey800,
    ),
  ),
)

// ❌ 不好的示例
Container(
  padding: const EdgeInsets.all(16), // 魔法数字
  decoration: BoxDecoration(
    color: Colors.white, // 硬编码颜色
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 14), // 硬编码样式
  ),
)
```

#### 国际化所有文本

```dart
// ✅ 好的示例
Text(FlutterI18n.translate(context, 'login.title'))

// ❌ 不好的示例
Text('登录') // 硬编码文本
```

#### 提供加载和错误状态

```dart
// ✅ 好的示例
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(viewModelProvider);

  if (state.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (state.errorMessage != null) {
    return ErrorMessage(message: state.errorMessage!);
  }

  return _buildContent(state);
}

// ❌ 不好的示例
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(viewModelProvider);
  return _buildContent(state); // 没有处理加载和错误状态
}
```

### 4. 性能优化

#### 使用 const 构造函数

```dart
// ✅ 好的示例
const SizedBox(height: AppSpacing.md)
const Icon(Icons.home)

// ❌ 不好的示例
SizedBox(height: AppSpacing.md)
Icon(Icons.home)
```

#### 避免在 build 方法中创建对象

```dart
// ✅ 好的示例
class MyWidget extends StatelessWidget {
  static const _padding = EdgeInsets.all(16);
  
  @override
  Widget build(BuildContext context) {
    return Container(padding: _padding);
  }
}

// ❌ 不好的示例
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16), // 每次 build 都创建新对象
    );
  }
}
```

## 常见问题

### Q: 如何添加新的 API 端点？

1. 在对应的 Service 中添加方法
2. 在 ViewModel 中调用 Service 方法
3. 在 Page 中使用 ViewModel

### Q: 如何添加新的国际化文本？

1. 在 `assets/flutter_i18n/zh_CN.json` 中添加中文
2. 在 `assets/flutter_i18n/en.json` 中添加英文
3. 在代码中使用 `FlutterI18n.translate(context, 'key')`

### Q: 如何处理导航？

使用 `go_router`：

```dart
// 跳转
context.push(RouteName.profile);

// 跳转并传参
context.push(
  RouteName.design3d,
  extra: {'flatDesignId': id},
);

// 返回
context.pop();
```

### Q: 如何调试网络请求？

1. 查看控制台日志
2. 使用 Charles 或 Fiddler 抓包
3. 在 ApiClient 的拦截器中添加日志

---

**遵循这些规范，让代码更加清晰、可维护！** 🎯
