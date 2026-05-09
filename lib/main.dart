import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neolivra/config/settings_service.dart';
import 'package:neolivra/screens/login_screen.dart';
import 'package:neolivra/screens/profile_screen.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'controllers/app_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final service = SettingsService();
  final isDark = await service.loadTheme();

  themeController.setTheme(isDark);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
          
          routes: {
            '/home': (context) => HomeScreen(),
            '/login': (context) => LoginScreen(),
            '/profile': (context) => ProfileScreen(),
          },
          home: StreamBuilder<User?>(
            stream: AuthService().authStateChanges,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return snapshot.data == null
                  ? const LoginScreen()
                  : const HomeScreen();
            },
          ),
        );
      },
    );
  }
}
