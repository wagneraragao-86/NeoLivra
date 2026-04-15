import 'package:flutter/material.dart';
import 'package:neolivra/theme/App_Background.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final PageController _pageController =
      PageController(viewportFraction: 0.75);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('NeoLivra'), centerTitle: true),

        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [

            // 🔥 HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "NeoLivra",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Leia, ouça, compartilhe",
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.person),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🔥 CONTINUAR LENDO
            _continueReading(),

            const SizedBox(height: 28),

            const Text(
              "Destaques",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _carousel(),

            const SizedBox(height: 28),

            Row(
              children: [
                _actionButton(
                  icon: Icons.menu_book, 
                  label: "Biblioteca", 
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LibraryScreen()),
                    );
                  },
                ),
                _actionButton(icon: Icons.volume_up, label: "Ouvir", onTap: () {}),
                _actionButton(
                  icon: Icons.settings,
                  label: "Config",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip("Tecnologia"),
                _chip("Negócios"),
                _chip("Ficção"),
                _chip("Autoajuda"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CONTINUE READING
  Widget _continueReading() {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppTheme.midBlue, AppTheme.deepBlue],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonGreen.withOpacity(0.4),
            blurRadius: 25,
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(width: 90),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Continue lendo", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 6),
                  Text(
                    "Atomic Habits",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  LinearProgressIndicator(value: 0.5),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 CARROSSEL
  Widget _carousel() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: 5,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1;

              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.7, 1);
              }

              return Transform.scale(
                scale: value,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.midBlue,
                        AppTheme.neonGreen.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔹 BOTÃO
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, size: 26, color: Colors.white),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label),
    );
  }
}