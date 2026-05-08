import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Whether Supabase has been initialized successfully.
bool get isSupabaseReady => SupabaseEnv.isConfigured;

SupabaseClient get supabase {
  if (!SupabaseEnv.isConfigured) {
    throw StateError(
      'Supabase not configured. Run with '
      '--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }
  return Supabase.instance.client;
}
