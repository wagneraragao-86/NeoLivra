import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Paleta oficial
  static const Color deepBlue = Color(0xFF0A1F44);
  static const Color midBlue = Color(0xFF123A7A);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color softGreen = Color(0xFF2EDB6C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFB0B8C1);
  static const LinearGradient lightGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFB0B8C1),
    ],
    begin: AlignmentGeometry.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [
      Color(0xFF0A1F44),
      Color(0xFF123A7A),
    ],
    begin: AlignmentGeometry.topLeft,
    end: AlignmentGeometry.bottomRight,
  );

  // 🌙 Tema escuro principal
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: deepBlue,

    colorScheme: const ColorScheme.dark(
      //primary: midBlue,
      //secondary: neonGreen,
      //surface: midBlue,
    ),

    // 🔝 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // 📝 Textos
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: white,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: grey,
      ),
    ),

    // 🔘 Botões
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: midBlue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // 🟩 Cards
    cardTheme: CardThemeData(
      color: midBlue,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // 🎯 Ícones
    iconTheme: const IconThemeData(
      color: white,
      size: 26,
    ),

    // 🟢 FAB (botão flutuante)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: neonGreen,
      foregroundColor: Colors.black,
    ),

    // 🎚️ Slider (usado na velocidade de leitura)
    sliderTheme: const SliderThemeData(
      activeTrackColor: neonGreen,
      inactiveTrackColor: grey,
      thumbColor: neonGreen,
      overlayColor: softGreen,
    ),

    // 🔄 Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(neonGreen),
      trackColor: WidgetStateProperty.all(softGreen.withOpacity(0.5)),
    ),
  );
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: white,

    colorScheme: const ColorScheme.light(
      primary: grey,
      secondary: grey,
      surface: softGreen,
    ),

    // 🔝 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: deepBlue),
      titleTextStyle: TextStyle(
        color: midBlue,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    // 📝 Textos
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: deepBlue,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: midBlue,
      ),
    ),

    // 🔘 Botões
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: grey,
        foregroundColor: midBlue,
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // 🟩 Cards
    cardTheme: CardThemeData(
      color: softGreen,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // 🎯 Ícones
    iconTheme: const IconThemeData(
      color: deepBlue,
      size: 26,
    ),

    // 🟢 FAB (botão flutuante)
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: midBlue,
      foregroundColor: grey,
    ),

    // 🎚️ Slider (usado na velocidade de leitura)
    sliderTheme: const SliderThemeData(
      activeTrackColor: deepBlue,
      inactiveTrackColor: grey,
      thumbColor: deepBlue,
      overlayColor: midBlue,
    ),

    // 🔄 Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(deepBlue),
      trackColor: WidgetStateProperty.all(midBlue.withOpacity(0.5)),
    ),
  );  
}