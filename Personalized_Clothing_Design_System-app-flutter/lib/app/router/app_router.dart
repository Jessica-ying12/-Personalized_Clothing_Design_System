import 'package:go_router/go_router.dart';

import '../../pages/home/home_page.dart';
import '../../pages/test/test_page.dart';
import '../../pages/unimp_demo/unimp_demo_page.dart';
import 'route_names.dart';

final router = GoRouter(
  initialLocation: RouteName.home,
  routes: [
    GoRoute(
      path: RouteName.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: RouteName.test,
      builder: (context, state) => const TestPage(),
    ),
    GoRoute(
      path: RouteName.unimpDemo,
      builder: (context, state) => const UniMPDemoPage(),
    ),
  ],
);
