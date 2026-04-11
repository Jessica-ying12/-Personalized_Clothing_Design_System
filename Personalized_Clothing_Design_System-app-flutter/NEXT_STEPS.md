# 下一步开发指南

## 最新进展 ✅

### 已完成的新功能

1. **设计选项加载** ✅
   - 在 DesignFlatViewModel 中实现了选项加载
   - 支持从后端加载所有设计选项（版型、花纹、材质等）
   - 在右侧面板显示选项列表
   - 支持选项选择和高亮显示

2. **平面图生成流程** ✅
   - 实现了完整的生成流程
   - 支持轮询检查生成状态
   - 显示生成进度和错误信息
   - 支持重新生成功能

3. **仓库页面数据加载** ✅
   - 从后端加载平面图和立体图列表
   - 支持删除设计
   - 支持重新生成
   - 添加了详情弹窗

4. **UI 组件** ✅
   - EmptyState - 空状态组件
   - ErrorMessage - 错误提示组件
   - LoadingOverlay - 加载遮罩组件

## 待完成的工作

### 1. 立体图生成页面 🔄

需要完善 `Design3dPage` 和 `Design3dViewModel`：

```dart
// 在 Design3dViewModel 中
@override
Design3dState build() {
  loadOptions();
  return const Design3dState();
}

Future<void> loadOptions() async {
  final service = ref.read(designOptionsServiceProvider);
  
  final bodyShapeOptions = await service.getOptions(category: 'body_shape');
  final skinColorOptions = await service.getOptions(category: 'skin_color');
  final genderOptions = await service.getOptions(category: 'gender');
  final backgroundOptions = await service.getOptions(category: 'background');
  final modelOptions = await service.getOptions(category: 'ai_model');
  
  state = state.copyWith(
    bodyShapeOptions: bodyShapeOptions,
    skinColorOptions: skinColorOptions,
    genderOptions: genderOptions,
    backgroundOptions: backgroundOptions,
    modelOptions: modelOptions,
  );
}
```

### 2. 路由参数传递 🔄

需要在 Design3dPage 中接收 flatDesignId：

```dart
// 在 app_router.dart 中
GoRoute(
  path: RouteName.design3d,
  builder: (context, state) {
    final flatDesignId = state.extra as String?;
    return Design3dPage(flatDesignId: flatDesignId);
  },
),

// 在 Design3dPage 中
class Design3dPage extends ConsumerStatefulWidget {
  const Design3dPage({super.key, this.flatDesignId});
  
  final String? flatDesignId;
  
  @override
  ConsumerState<Design3dPage> createState() => _Design3dPageState();
}

// 在 initState 中初始化
@override
void initState() {
  super.initState();
  if (widget.flatDesignId != null) {
    Future.microtask(() {
      ref.read(design3dViewModelProvider.notifier)
          .initialize(widget.flatDesignId!);
    });
  }
}
```

### 3. 图片下载功能 📝

实现图片下载到本地：

```dart
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> downloadImage(String url, String fileName) async {
  // 请求存储权限
  final status = await Permission.storage.request();
  if (!status.isGranted) return;
  
  // 获取下载目录
  final dir = await getExternalStorageDirectory();
  final savePath = '${dir!.path}/$fileName';
  
  // 下载文件
  final dio = Dio();
  await dio.download(url, savePath);
  
  // 显示成功提示
}
```

### 4. 历史记录页面 📝

创建历史记录页面：

```dart
// lib/pages/history/history_page.dart
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 使用 flatDesignService.getHistory() 和 design3dService.getHistory()
    // 显示所有记录，包括已删除的
    // 支持重新保存到仓库
  }
}
```

### 5. 图片缓存 📝

添加图片缓存以提升性能：

```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.0
```

```dart
// 使用 CachedNetworkImage 替代 Image.network
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

### 6. 分页加载 📝

实现仓库页面的分页加载：

```dart
class GalleryViewModel extends Notifier<GalleryState> {
  int _currentPage = 1;
  bool _hasMore = true;
  
  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    
    _currentPage++;
    final result = await service.getList(page: _currentPage);
    
    _hasMore = result['data'].isNotEmpty;
    state = state.copyWith(
      flatDesigns: [...state.flatDesigns, ...result['data']],
    );
  }
}

// 在 ListView 中添加滚动监听
ScrollController _scrollController = ScrollController();

@override
void initState() {
  super.initState();
  _scrollController.addListener(() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      viewModel.loadMore();
    }
  });
}
```

### 7. 错误处理优化 📝

添加全局错误处理和用户友好的提示：

```dart
// lib/core/utils/error_handler.dart
class ErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    String message = '操作失败';
    
    if (error is DioException) {
      message = error.error?.toString() ?? '网络请求失败';
    } else {
      message = error.toString();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}
```

### 8. 加载状态优化 📝

使用骨架屏替代简单的加载指示器：

```yaml
dependencies:
  shimmer: ^3.0.0
```

```dart
import 'package:shimmer/shimmer.dart';

Widget _buildShimmer() {
  return Shimmer.fromColors(
    baseColor: AppColors.grey100,
    highlightColor: AppColors.grey50,
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        );
      },
    ),
  );
}
```

## 测试清单

### 功能测试

- [ ] 登录注册流程
- [ ] 设计选项加载
- [ ] 平面图生成
- [ ] 立体图生成
- [ ] 仓库列表展示
- [ ] 图片下载
- [ ] 重新生成
- [ ] 删除设计
- [ ] 退出登录
- [ ] 注销账号

### 错误场景测试

- [ ] 网络断开时的错误提示
- [ ] API 返回错误时的处理
- [ ] Token 过期时的处理
- [ ] 生成失败时的提示
- [ ] 图片加载失败时的占位图

### 性能测试

- [ ] 大量图片加载时的性能
- [ ] 滚动流畅度
- [ ] 内存占用
- [ ] 图片缓存效果

## 优化建议

### 1. 代码组织

- 将共享的 UI 组件提取到 `lib/shared/widgets/`
- 将工具函数提取到 `lib/shared/utils/`
- 将常量定义提取到 `lib/core/constants/`

### 2. 状态管理

- 考虑使用 AsyncNotifier 处理异步状态
- 添加状态持久化（保存用户选择）
- 实现状态恢复（应用重启后恢复状态）

### 3. 用户体验

- 添加页面切换动画
- 添加操作反馈（震动、声音）
- 添加引导页（首次使用）
- 添加设置页面（语言切换、主题切换）

### 4. 性能优化

- 使用 const 构造函数
- 避免不必要的 rebuild
- 使用 ListView.builder 而不是 ListView
- 图片压缩和懒加载

## 发布前检查

- [ ] 更新 Supabase URL 配置
- [ ] 检查所有 TODO 注释
- [ ] 运行 `flutter analyze` 无错误
- [ ] 运行 `flutter test` 所有测试通过
- [ ] 检查应用图标和启动页
- [ ] 检查应用权限配置
- [ ] 准备应用商店截图和描述
- [ ] 配置应用签名
- [ ] 生成发布版本

## 参考资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev)
- [Dio 文档](https://pub.dev/packages/dio)
- [GoRouter 文档](https://pub.dev/packages/go_router)
- [Material Design 指南](https://m3.material.io)
