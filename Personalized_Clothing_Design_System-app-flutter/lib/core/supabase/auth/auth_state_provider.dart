import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_repository.dart';

final authStateProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authStateProvider).valueOrNull?.session?.user,
);
