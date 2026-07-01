import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/':
        return 0;
      case '/health_records':
        return 1;
      case '/medical_records':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/health_records');
      case 2:
        context.go('/medical_records');
      case 3:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _getCurrentIndex(context),
        onTap: (index) => _onTabTapped(context, index),
        selectedItemColor: const Color(0xFF007AFF),
        unselectedItemColor: AppColors.secondaryText,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '概览'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: '健康'),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: '医疗'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
