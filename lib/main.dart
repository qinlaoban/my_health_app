import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/health_provider.dart';
import 'providers/reminder_provider.dart';
import 'providers/app_settings_provider.dart';
import 'router/app_router.dart';

void main() {
  runApp(const MyHealthApp());
}

class MyHealthApp extends StatelessWidget {
  const MyHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()..load()),
        ChangeNotifierProvider(create: (_) => HealthProvider()..load()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()..load()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) => MaterialApp.router(
          title: '我的健康',
          theme: ThemeData(
            primaryColor: const Color(0xFF0569F1),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0569F1),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0569F1),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF0569F1),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0B56C0),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          themeMode: settings.themeMode,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
