import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/health_provider.dart';
import 'providers/reminder_provider.dart'
    ;
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
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: MaterialApp.router(
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
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
