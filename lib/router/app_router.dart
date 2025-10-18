import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/health_records_screen.dart';
import '../screens/health_charts_screen.dart';
import '../screens/medical_records_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/biomarkers_screen.dart';
import '../screens/scatter_chart_screen.dart';
import '../screens/reminders_screen.dart';
import '../widgets/main_navigation.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 主页面路由 - 使用ShellRoute来保持底部导航栏
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'dashboard',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/health_records',
          name: 'health_records',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const HealthRecordsScreen(),
          ),
        ),
        GoRoute(
          path: '/medical_records',
          name: 'medical_records',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const MedicalRecordsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
    // 独立页面路由 - 不使用底部导航栏
    GoRoute(
      path: '/health-charts',
      name: 'health_charts',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const HealthChartsScreen(),
      ),
    ),
    GoRoute(
      path: '/biomarkers',
      name: 'biomarkers',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const BiomarkersScreen(),
      ),
    ),
    GoRoute(
      path: '/scatter-chart',
      name: 'scatter_chart',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const ScatterChartScreen(),
      ),
    ),
    GoRoute(
      path: '/reminders',
      name: 'reminders',
      pageBuilder: (context, state) => MaterialPage<void>(
        key: state.pageKey,
        child: const RemindersScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '页面未找到',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '路径: ${state.uri.path}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('返回首页'),
          ),
        ],
      ),
    ),
  ),
);