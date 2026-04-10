import 'package:flutter/material.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NeoLivra'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👋 Header
          const Text(
            "Olá 👋",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            "O que vamos ler hoje?",
            style: TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 24),

          // 📚 Card principal
          _mainCard(
            icon: Icons.menu_book,
            title: "Abrir Biblioteca",
            subtitle: "Acesse seus livros",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // ⚡ Ações rápidas
          const Text(
            "Ações rápidas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionButton(
                icon: Icons.auto_awesome,
                label: "Resumos",
                onTap: () {},
              ),
              _actionButton(
                icon: Icons.volume_up,
                label: "Ouvir",
                onTap: () {},
              ),
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

          const SizedBox(height: 24),

          // 🧠 Últimos resumos (placeholder)
          const Text(
            "Últimos resumos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const ListTile(
              title: Text("Nenhum resumo ainda"),
              subtitle: Text("Seus resumos aparecerão aqui"),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Card principal
  Widget _mainCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppTheme.midBlue, AppTheme.neonGreen],
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Botões rápidos
  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white12,
            child: Icon(icon, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }
}
