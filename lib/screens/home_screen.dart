import 'package:flutter/material.dart';
import 'package:neolivra/theme/App_Background.dart';

import '../models/reading_stats.dart';
import '../services/firestore_service.dart';
import '../services/stats_storage.dart';
import '../theme/app_theme.dart';
import 'library_screen.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  final StatsStorage _statsStorage = StatsStorage();

  late Future<ReadingStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _statsStorage.load();
  }

  Future<void> _refreshStats() async {
    setState(() {
      _statsFuture = _statsStorage.load();
    });
  }

  Future<void> _abrirUltimoLivro(ReadingStats stats) async {
    if (stats.lastOpenedBookId.isEmpty) {
      return;
    }

    final livro = await FirestoreService().buscarLivroPorId(
      stats.lastOpenedBookId,
    );

    if (!mounted || livro == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(book: livro)),
    );

    await _refreshStats();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('NeoLivra'), centerTitle: true),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "NeoLivra",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Leia, ouca, compartilhe",
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
            FutureBuilder<ReadingStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                final stats = snapshot.data;
                return _continueReading(stats);
              },
            ),
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LibraryScreen(),
                      ),
                    );
                    await _refreshStats();
                  },
                ),
                _actionButton(
                  icon: Icons.volume_up,
                  label: "Ouvir",
                  onTap: () {},
                ),
                _actionButton(
                  icon: Icons.settings,
                  label: "Config",
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                    await _refreshStats();
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
                _chip("Negocios"),
                _chip("Ficcao"),
                _chip("Autoajuda"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _continueReading(ReadingStats? stats) {
    final hasBook = stats != null && stats.lastOpenedBookId.isNotEmpty;
    final progress = (stats?.lastOpenedProgress ?? 0).clamp(0.0, 1.0);
    final progressPercent = (progress * 100).round();

    return GestureDetector(
      onTap: hasBook ? () => _abrirUltimoLivro(stats) : null,
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [AppTheme.midBlue, AppTheme.deepBlue],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonGreen.withOpacity(0.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 98,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: hasBook
                        ? [
                            AppTheme.neonGreen.withOpacity(0.85),
                            AppTheme.softGreen.withOpacity(0.75),
                          ]
                        : [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.08),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
                child: Icon(
                  hasBook ? Icons.menu_book_rounded : Icons.book_outlined,
                  color: hasBook ? Colors.black : Colors.white70,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasBook
                          ? "Continue lendo"
                          : "Seu ultimo livro vai aparecer aqui",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasBook
                          ? stats.lastOpenedTitle
                          : "Abra um livro para começar",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasBook ? stats.lastOpenedAuthor : "NeoLivra",
                      style: const TextStyle(color: Colors.white60),
                    ),
                    const SizedBox(height: 12),
                    _progressBar(progress),
                    const SizedBox(height: 8),
                    Text(
                      hasBook
                          ? "$progressPercent% concluido"
                          : "0% concluido",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(double value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.neonGreen, AppTheme.softGreen],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.08),
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
