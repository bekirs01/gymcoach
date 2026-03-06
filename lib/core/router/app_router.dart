import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/exercises/exercise_detail_screen.dart';
import '../../presentation/screens/guide/guide_article_detail_screen.dart';
import '../../presentation/screens/guide/guide_screen.dart';
import '../../presentation/screens/initial_redirect.dart';
import '../../presentation/screens/main/main_shell.dart';
import '../../presentation/screens/onboarding/onboarding_flow_screen.dart';
import '../../presentation/screens/plan/create_plan_screen.dart';
import '../../presentation/screens/plan/plan_detail_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';

/// Uygulama routing yapılandırması
class AppRouter {
  AppRouter(this._rootNavigatorKey);

  final GlobalKey<NavigatorState> _rootNavigatorKey;

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const InitialRedirect(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '/exercise/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ExerciseDetailScreen(exerciseId: id);
        },
      ),
      GoRoute(
        path: '/guide',
        builder: (context, state) => const GuideScreen(),
      ),
      GoRoute(
        path: '/guide/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GuideArticleDetailScreen(articleId: id);
        },
      ),
      GoRoute(
        path: '/plan/create',
        builder: (context, state) => const CreatePlanScreen(),
      ),
      GoRoute(
        path: '/plan/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlanDetailScreen(planId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
