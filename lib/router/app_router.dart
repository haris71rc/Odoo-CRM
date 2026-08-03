import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:odoocrm/features/analytics/presentation/analytics_page.dart';
import 'package:odoocrm/features/auth/presentation/login/login_page.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/leads/presentation/lead_detail/lead_detail_page.dart';
import 'package:odoocrm/features/leads/presentation/lead_list/lead_list_page.dart';
import 'package:odoocrm/features/shell/home_shell.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

class _RouterRefresh extends ChangeNotifier {
  void ping() => notifyListeners();
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = _RouterRefresh();

  ref.listen(authNotifierProvider, (previous, next) {
    refresh.ping();
  });

  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/leads',
    refreshListenable: refresh,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final loggingIn = state.matchedLocation == '/login';

      if (authState.isLoading) return null;

      final isLoggedIn = authState.valueOrNull != null;

      if (!isLoggedIn && !loggingIn) return '/login';
      if (isLoggedIn && loggingIn) return '/leads';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/leads',
                builder: (context, state) => const LeadListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/leads/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return LeadDetailPage(leadId: id);
        },
      ),
    ],
  );
}
