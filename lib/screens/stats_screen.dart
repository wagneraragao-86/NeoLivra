import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neolivra/theme/app_theme.dart';
import '../services/stats_storage.dart';
import '../models/reading_stats.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final storage = StatsStorage();
  ReadingStats? stats;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    stats = await storage.load();
    setState(() {});
  }

  List<FlSpot> gerarPontos() {
    final entries = stats!.dailyReading.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    int index = 0;

    return entries.map((e) {
      final spot = FlSpot(index.toDouble(), e.value.toDouble());
      index++;
      return spot;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final spots = gerarPontos();

    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Seu progresso")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text("Minutos lidos: ${stats!.totalMinutes}"),
              Text("Livros abertos: ${stats!.booksOpened}"),
              Text("Streak: ${stats!.streakDays} dias"),
              const SizedBox(height: 20),

              const Text("Leitura por dia"),
              const SizedBox(height: 10),

              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(spots: spots, isCurved: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
