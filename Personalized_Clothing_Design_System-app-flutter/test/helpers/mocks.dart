import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import 'package:livhome/core/supabase/auth/auth_repository.dart';
import 'package:livhome/core/network/api/website/website_api.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBox extends Mock implements Box {}

class MockWebsiteApi extends Mock implements WebsiteApi {}

// Supabase value fakes
class FakeAuthResponse extends Fake implements AuthResponse {}

class FakeUser extends Fake implements User {
  @override
  String get id => 'test-uid-123';

  @override
  String get email => 'test@example.com';
}
