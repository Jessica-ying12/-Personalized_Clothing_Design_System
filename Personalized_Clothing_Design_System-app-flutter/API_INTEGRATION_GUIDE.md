# API 集成指南

## 已完成的工作

### 1. 核心架构

已创建完整的 API 集成架构：

- **API Client** (`lib/core/api/api_client.dart`)
  - 基于 Dio 的 HTTP 客户端
  - 自动添加认证 Token
  - 统一错误处理

- **拦截器**
  - `AuthInterceptor`: 自动添加 Authorization Header
  - `ErrorInterceptor`: 统一处理 API 错误

- **安全存储** (`lib/core/storage/secure_storage.dart`)
  - 使用 flutter_secure_storage 安全存储 Token
  - 存储用户 ID 和邮箱

### 2. 数据模型

已创建所有业务数据模型：

- `UserModel` - 用户信息
- `DesignOptionModel` - 设计选项（版型、花纹、材质等）
- `FlatDesignModel` - 平面图设计
- `Design3dModel` - 立体图设计

### 3. Service 层

已创建所有 API Service：

- `AuthService` - 认证服务（登录、注册、获取用户信息）
- `ProfileService` - 用户资料服务（更新资料、注销账号、统计信息）
- `DesignOptionsService` - 设计选项服务（获取选项列表）
- `FlatDesignService` - 平面图服务（生成、重新生成、列表、历史记录）
- `Design3dService` - 立体图服务（生成、重新生成、切换背景、列表）

### 4. 已集成的页面

- **LoginPage** - 已集成登录和注册 API
- **ProfilePage** - 已集成用户信息加载、退出登录、注销账号

## 配置步骤

### 1. 安装依赖

在 `pubspec.yaml` 中添加以下依赖：

```yaml
dependencies:
  dio: ^5.4.0
  flutter_secure_storage: ^9.0.0
  flutter_riverpod: ^2.4.9
  go_router: ^13.0.0
  flutter_i18n: ^0.35.1
```

运行：
```bash
flutter pub get
```

### 2. 配置 Supabase URL

编辑 `lib/core/config/app_config.dart`，替换为你的 Supabase 项目 URL：

```dart
static const String supabaseUrl = 'https://your-project-ref.supabase.co';
```

### 3. 配置环境变量（可选）

如果需要支持多环境（开发、预览、生产），可以使用 `.env` 文件：

```
SUPABASE_URL=https://your-project-ref.supabase.co
```

## 待完成的集成

### 1. 设计选项加载

在 `DesignFlatPage` 和 `Design3dPage` 中需要：

1. 在页面初始化时加载设计选项
2. 根据分类显示选项列表
3. 支持二级选项的加载和显示

示例代码：

```dart
// 在 DesignFlatViewModel 中
Future<void> loadOptions() async {
  final service = ref.read(designOptionsServiceProvider);
  
  // 加载版型选项
  final silhouettes = await service.getOptions(category: 'silhouette');
  
  // 加载花纹选项
  final patterns = await service.getOptions(category: 'pattern');
  
  // ... 其他选项
}

// 加载二级选项
Future<void> loadChildren(String parentId) async {
  final service = ref.read(designOptionsServiceProvider);
  final children = await service.getChildren(parentId);
  // 更新状态
}
```

### 2. 平面图生成

在 `DesignFlatViewModel.generateFlatDesign()` 中：

```dart
Future<void> generateFlatDesign() async {
  if (!state.canGenerate) return;

  state = state.copyWith(isGenerating: true);

  try {
    final service = ref.read(flatDesignServiceProvider);
    final design = await service.generate(
      silhouetteId: state.selectedClothingType!,
      patternId: state.selectedPattern!,
      materialId: state.selectedMaterial!,
      styleId: state.selectedStyle!,
      audienceId: state.selectedAudience!,
      aiModelId: state.selectedModel!,
      params: {}, // 从 UI 收集的参数
    );

    // 轮询检查生成状态
    await _pollGenerationStatus(design.id);
  } catch (e) {
    state = state.copyWith(
      isGenerating: false,
      errorMessage: e.toString(),
    );
  }
}

Future<void> _pollGenerationStatus(String designId) async {
  final service = ref.read(flatDesignServiceProvider);
  
  while (true) {
    await Future.delayed(const Duration(seconds: 2));
    
    final status = await service.getStatus(designId);
    
    if (status['status'] == 'done') {
      state = state.copyWith(
        isGenerating: false,
        generatedImageUrl: status['image_url'],
      );
      break;
    } else if (status['status'] == 'failed') {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: status['error_msg'],
      );
      break;
    }
  }
}
```

### 3. 立体图生成

类似平面图生成，在 `Design3dViewModel` 中实现。

### 4. 仓库页面

在 `GalleryViewModel.loadDesigns()` 中：

```dart
Future<void> loadDesigns() async {
  state = state.copyWith(isLoading: true);

  try {
    final flatService = ref.read(flatDesignServiceProvider);
    final design3dService = ref.read(design3dServiceProvider);

    final flatResult = await flatService.getList(page: 1, pageSize: 20);
    final design3dResult = await design3dService.getList(page: 1, pageSize: 20);

    state = state.copyWith(
      isLoading: false,
      flatDesigns: (flatResult['data'] as List<FlatDesignModel>)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl ?? '',
                createdAt: e.createdAt ?? DateTime.now(),
              ))
          .toList(),
      design3ds: (design3dResult['data'] as List<Design3dModel>)
          .map((e) => DesignItem(
                id: e.id,
                imageUrl: e.imageUrl ?? '',
                createdAt: e.createdAt ?? DateTime.now(),
              ))
          .toList(),
    );
  } catch (e) {
    state = state.copyWith(isLoading: false);
  }
}
```

## 错误处理

所有 API 调用都应该使用 try-catch 包裹：

```dart
try {
  final result = await service.someMethod();
  // 处理成功结果
} catch (e) {
  // 显示错误消息
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
```

## 测试

### 1. 测试登录流程

1. 启动应用
2. 输入邮箱和密码
3. 点击登录
4. 检查是否跳转到主页面

### 2. 测试 Token 持久化

1. 登录成功后关闭应用
2. 重新打开应用
3. 应该自动保持登录状态

### 3. 测试 API 错误处理

1. 输入错误的邮箱密码
2. 检查是否显示错误消息
3. 断开网络连接
4. 检查是否显示网络错误

## 下一步

1. 完成设计选项的加载和显示
2. 实现平面图和立体图的生成流程
3. 实现仓库页面的数据加载
4. 添加图片下载功能
5. 添加历史记录页面
6. 优化 UI 和交互细节
7. 添加加载动画和骨架屏
8. 完善错误提示和用户反馈
