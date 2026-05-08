import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/env.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/community/community_screen.dart';
import '../features/community/post_detail_screen.dart';
import '../features/home/home_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/publish/diet_form_screen.dart';
import '../features/publish/exercise_form_screen.dart';
import '../features/publish/publish_hub_screen.dart';
import '../features/publish/weight_form_screen.dart';
import '../features/stats/stats_screen.dart';
import 'auth_refresh.dart';
import 'main_shell.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthRefreshNotifier? authRefresh) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      if (!SupabaseEnv.isConfigured) return null;
      final session = Supabase.instance.client.auth.currentSession;
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/register';
      if (session == null && !loggingIn) return '/login';
      if (session != null && loggingIn) return '/home';
      return null;
    },
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/community',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: CommunityScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/publish',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: PublishHubScreen()),
                routes: [
                  GoRoute(
                    path: 'diet',
                    builder: (context, state) => const DietFormScreen(),
                  ),
                  GoRoute(
                    path: 'exercise',
                    builder: (context, state) => const ExerciseFormScreen(),
                  ),
                  GoRoute(
                    path: 'weight',
                    builder: (context, state) => const WeightFormScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: StatsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PostDetailScreen(postId: id);
        },
      ),
    ],
  );
}
