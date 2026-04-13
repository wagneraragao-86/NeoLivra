import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neolivra/config/settings_service.dart';
import 'package:neolivra/screens/library_screen.dart';
import 'package:neolivra/controllers/app_controller.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'theme/theme_controller.dart';
import 'controllers/app_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = SettingsService();
  final isDark = await service.loadTheme();

  themeController.setTheme(isDark);

  // Inicializa Firebase corretamente
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService().loginAnonimo();

  runApp(const NeoLivraApp());
}

class NeoLivraApp extends StatelessWidget {
  const NeoLivraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.isDark
            ? ThemeMode.dark
            : ThemeMode.light,
          home: HomeScreen(),
        );
      },
    );
  }
}
