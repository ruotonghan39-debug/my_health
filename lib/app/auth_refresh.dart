import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Drives [GoRouter.redirect] when Supabase auth session changes.
class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(SupabaseClient client) : _client = client {
    _sub = _client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }

  final SupabaseClient _client;
  StreamSubscription<AuthState>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
