import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../design_flat/design_flat_page.dart';
import '../gallery/gallery_page.dart';
import '../profile/profile_page.dart';
import 'main_view_model.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainViewModelProvider);
    final viewModel = ref.read(mainViewModelProvider.notifier);

    final pages = [
      const DesignFlatPage(),
      const GalleryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: state.currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.currentIndex,
        onTap: viewModel.setCurrentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.design_services),
            label: FlutterI18n.translate(context, 'nav.customize'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.photo_library),
            label: FlutterI18n.translate(context, 'nav.gallery'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: FlutterI18n.translate(context, 'nav.profile'),
          ),
        ],
      ),
    );
  }
}
