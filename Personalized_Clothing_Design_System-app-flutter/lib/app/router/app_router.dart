import 'package:go_router/go_router.dart';

import '../../pages/design_3d/design_3d_page.dart';
import '../../pages/design_flat/design_flat_page.dart';
import '../../pages/gallery/gallery_page.dart';
import '../../pages/history/history_page.dart';
import '../../pages/login/login_page.dart';
import '../../pages/main/main_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../pages/profile_edit/profile_edit_page.dart';
import '../../pages/splash/splash_page.dart';
import 'route_names.dart';

final router = GoRouter(
  initialLocation: RouteName.splash,
  routes: [
    GoRoute(
      path: RouteName.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteName.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteName.main,
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: RouteName.designFlat,
      builder: (context, state) => const DesignFlatPage(),
    ),
    GoRoute(
      path: RouteName.design3d,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return Design3dPage(
          flatDesignId: extra?['flatDesignId'] as String?,
          flatImageUrl: extra?['flatImageUrl'] as String?,
        );
      },
    ),
    GoRoute(
      path: RouteName.gallery,
      builder: (context, state) => const GalleryPage(),
    ),
    GoRoute(
      path: RouteName.profile,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      path: RouteName.profileEdit,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ProfileEditPage(
          fullName: extra?['fullName'] as String?,
          avatarUrl: extra?['avatarUrl'] as String?,
        );
      },
    ),
    GoRoute(
      path: RouteName.history,
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);
