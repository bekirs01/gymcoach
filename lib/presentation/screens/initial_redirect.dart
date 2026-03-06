import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import 'onboarding/onboarding_flow_screen.dart';

/// Uygulama açılışında onboarding durumuna göre yönlendirme
class InitialRedirect extends ConsumerWidget {
  const InitialRedirect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(onboardingCompleteProvider);

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const OnboardingFlowScreen(),
      data: (complete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (complete) {
            context.go('/main');
          } else {
            context.go('/onboarding');
          }
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
