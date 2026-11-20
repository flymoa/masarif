import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/models.dart';
import 'data/repo.dart';
import 'screens/notifs.dart';
import 'screens/tx_detail.dart';
import 'screens/add_tx.dart';
import 'screens/auth.dart';
import 'screens/categories.dart';
import 'screens/home.dart';
import 'screens/profile.dart';
import 'screens/savings.dart';
import 'screens/shell.dart';
import 'screens/splash.dart';
import 'screens/stats.dart';
import 'screens/transactions.dart';

const _authRoutes = {'/login', '/signup', '/forgot'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authProvider, (_, __) => refresh.value++);
  ref.listen(splashDoneProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loc = state.matchedLocation;
      // Splash kayb9a 7ta tsali l animation o l auth tkoun jahza.
      if (auth.isLoading || !ref.read(splashDoneProvider)) return loc == '/splash' ? null : '/splash';
      final loggedIn = auth.value != null;
      if (!loggedIn) return _authRoutes.contains(loc) ? null : '/login';
      if (_authRoutes.contains(loc) || loc == '/splash') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tx',
              builder: (_, s) => TransactionsScreen(
                initialCat: s.uri.queryParameters['cat'],
                initialMonth: s.uri.queryParameters['month'],
              ),
            ),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/stats', builder: (_, __) => const StatsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
        ],
      ),
      GoRoute(
        path: '/add',
        pageBuilder: (_, s) => MaterialPage(
          fullscreenDialog: true,
          child: AddTxScreen(initialType: s.uri.queryParameters['type'] == 'income' ? TxType.income : TxType.expense),
        ),
      ),
      GoRoute(path: '/tx/:id', builder: (_, s) => TxDetailScreen(txId: s.pathParameters['id']!)),
      GoRoute(path: '/tx/:id/edit', builder: (_, s) => AddTxScreen(txId: s.pathParameters['id'])),
      GoRoute(path: '/notifs', builder: (_, __) => const NotifsScreen()),
      GoRoute(path: '/month/:key', builder: (_, s) => MonthDetailScreen(monthKey: s.pathParameters['key']!)),
      GoRoute(path: '/categories', builder: (_, __) => const CategoriesScreen()),
      GoRoute(path: '/categories/edit', builder: (_, s) => CategoryEditScreen(catId: s.uri.queryParameters['id'])),
      GoRoute(path: '/savings', builder: (_, __) => const SavingsScreen()),
      GoRoute(
        path: '/savings/move',
        pageBuilder: (_, s) => MaterialPage(
          fullscreenDialog: true,
          child: SavingsMoveScreen(mode: s.uri.queryParameters['mode'] ?? 'put'),
        ),
      ),
    ],
  );
});
