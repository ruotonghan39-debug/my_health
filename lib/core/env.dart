/// Compile-time config via `--dart-define=SUPABASE_URL=...` etc.
abstract final class SupabaseEnv {
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
