import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_router.dart';
import 'app/auth_refresh.dart';
import 'core/env.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRefreshNotifier? authRefresh;
  if (SupabaseEnv.isConfigured) {
    await Supabase.initialize(
      url: SupabaseEnv.url,
      anonKey: SupabaseEnv.anonKey,
    );
    authRefresh = AuthRefreshNotifier(Supabase.instance.client);
  }

  final router = createRouter(authRefresh);

  runApp(
    ProviderScope(
      child: TinyBurnApp(router: router),
    ),
  );
}

class TinyBurnApp extends StatelessWidget {
  const TinyBurnApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '轻燃',
      debugShowCheckedModeBanner: false,
      theme: buildTinyBurnTheme(),
      routerConfig: router,
    );
  }
}
