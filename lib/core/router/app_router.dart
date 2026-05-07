import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../responsive/adaptive_scaffold.dart';
import '../../screens/home_screen.dart';
import '../../screens/health_screen.dart';
import '../../screens/sekolah_screen.dart';
import '../../screens/dosen_search_screen_new.dart';
import '../../screens/prodi_search_screen.dart';
import '../../screens/detail_screen.dart';
import '../../screens/dosen_detail_screen.dart';
import '../../features/procurement/presentation/screens/procurement_dashboard_screen.dart';
import '../../features/statistics/presentation/screens/statistics_dashboard_screen.dart';
import '../../features/economy/presentation/screens/economy_dashboard_screen.dart';
import '../../features/disaster/presentation/screens/disaster_dashboard_screen.dart';
import '../../screens/prodi_detail_screen.dart';
import '../../screens/pt_detail_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Shell route with adaptive navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveScaffold(
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(index),
          destinations: const [],
          body: navigationShell,
        );
      },
      branches: [
        // Tab 0: Home/Education
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        ]),
        // Tab 1: Procurement
        StatefulShellBranch(routes: [
          GoRoute(path: '/procurement', builder: (_, __) => const ProcurementDashboardScreen()),
        ]),
        // Tab 2: Statistics
        StatefulShellBranch(routes: [
          GoRoute(path: '/statistics', builder: (_, __) => const StatisticsDashboardScreen()),
        ]),
        // Tab 3: Economy
        StatefulShellBranch(routes: [
          GoRoute(path: '/economy', builder: (_, __) => const EconomyDashboardScreen()),
        ]),
        // Tab 4: Disaster
        StatefulShellBranch(routes: [
          GoRoute(path: '/disaster', builder: (_, __) => const DisasterDashboardScreen()),
        ]),
      ],
    ),
    // Standalone routes
    GoRoute(path: '/health', builder: (_, __) => const HealthScreen()),
    GoRoute(path: '/sekolah', builder: (_, __) => const SekolahLookupScreen()),
    GoRoute(path: '/dosen/search', builder: (_, __) => const DosenSearchScreenNew()),
    GoRoute(path: '/prodi/search', builder: (_, __) => const ProdiSearchScreen()),
    GoRoute(
      path: '/mahasiswa/:id',
      builder: (_, state) => DetailScreen(
        mahasiswaId: state.pathParameters['id'] ?? '',
        subjectName: state.uri.queryParameters['name'] ?? 'Mahasiswa',
      ),
    ),
    GoRoute(
      path: '/dosen/:id',
      builder: (_, state) => DosenDetailScreen(
        dosenId: state.pathParameters['id'] ?? '',
        dosenName: state.uri.queryParameters['name'] ?? 'Dosen',
      ),
    ),
    GoRoute(
      path: '/prodi/:id',
      builder: (_, state) => ProdiDetailScreen(
        prodiId: state.pathParameters['id'] ?? '',
        prodiName: state.uri.queryParameters['name'] ?? 'Prodi',
      ),
    ),
    GoRoute(
      path: '/pt/:id',
      builder: (_, state) => PtDetailScreen(
        ptId: state.pathParameters['id'] ?? '',
        ptName: state.uri.queryParameters['name'] ?? 'PT',
      ),
    ),
  ],
);
