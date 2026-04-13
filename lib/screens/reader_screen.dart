import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:neolivra/theme/app_theme.dart';

import '../models/book.dart';
import '../services/library_storage.dart';
import '../services/stats_storage.dart';
import '../services/firestore_service.dart';
import '../config/settings_service.dart';
import '../services/summary_service.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final FlutterTts tts = FlutterTts();
  final ScrollController scrollController = ScrollController();
  final settingsService = SettingsService();

  late final LibraryStorage storage = LibraryStorage();
  late final StatsStorage statsStorage = StatsStorage();

  late DateTime startReading;

  bool isSpeaking = false;
  int paginaAtual = 0;
  String livroId = '';
  double velocidade = 0.5;
  double volume = 0.5;

  @override
  void initState() {
    super.initState();

    startReading = DateTime.now();
    registrarAberturaLivro();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(widget.book.position.toDouble());
      }
    });

    scrollController.addListener(() {
      widget.book.position = scrollController.offset.toInt();
    });
  }

  Future<void> registrarAberturaLivro() async {
    final stats = await statsStorage.load();
    stats.booksOpened += 1;
    await statsStorage.save(stats);
  }

  Future<void> registrarTempoLeitura() async {
    final stats = await statsStorage.load();

    final minutes = DateTime.now().difference(startReading).inMinutes;

    stats.totalMinutes += minutes;

    final today = DateTime.now().toIso8601String().substring(0, 10);

    // salva minutos por dia
    stats.dailyReading[today] = (stats.dailyReading[today] ?? 0) + minutes;

    if (stats.lastReadDate != today) {
      stats.streakDays += 1;
      stats.lastReadDate = today;
    }

    await statsStorage.save(stats);
  }

  /*Future<void> speak() async {
    await tts.stop();

    final settings = await settingsService.loadSettings();
    final velocidade = settings["rate"] ?? 0.5;
    final ignoreSuper = settings["ignoreSuper"];
    final ignoreSub = settings["ignoreSub"];
    final volume = settings["volume"];

    String textoFala = widget.book.conteudo;

    if (ignoreSuper) {
      textoFala = textoFala.replaceAll(RegExp(r'\^.?'), '');
    }

    if (ignoreSub) {
      textoFala = textoFala.replaceAll(RegExp(r'_.*?'), '');
    }

    await tts.setLanguage("pt-BR");
    await tts.setSpeechRate(velocidade);
    await tts.setPitch(1.0);
    await tts.setVolume(volume);

    if (settings["voice"] != null && settings["voice"] != 'default') {
      await tts.speak(widget.book.conteudo);

      setState(() => isSpeaking = true);
    }
  }*/
  Future<void> speak() async {
    final settings = await SettingsService().loadSettings();

    await tts.setSpeechRate(settings["rate"]);
    await tts.setVolume(settings["volume"]);

    if (settings["voice"] != 'default') {
      await tts.setVoice({"name": settings["voice"], "locale": "pt-BR"});
    }

    await tts.speak(widget.book.conteudo);

    setState(() => isSpeaking = true);
  }

  Future<void> stop() async {
    await tts.stop();
    setState(() => isSpeaking = false);
  }

  Future<void> gerarResumo() async {
    double percentual = 0.3; // padrão 30%

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        double temp = 0.3;

        return AlertDialog(
          title: const Text("Escolha o tamanho do resumo"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${(temp * 100).toInt()}%"),
                  Slider(
                    value: temp,
                    min: 0.1,
                    max: 0.5,
                    divisions: 40,
                    onChanged: (value) {
                      setState(() => temp = value);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, temp),
              child: const Text("Gerar"),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    // loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final service = SummaryService();

    final resumo = await service.gerarResumo(widget.book.conteudo, result);

    Navigator.pop(context); // fecha loading

    // salva no livro
    widget.book.resumo = resumo;

    // salva local
    await salvarProgresso();

    setState(() {});

    // abre tela
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text("Resumo")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(child: Text(resumo)),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    salvarProgresso();
    scrollController.dispose();
    tts.stop();
    registrarTempoLeitura();
    super.dispose();
  }

  Future<void> salvarProgresso() async {
    final livros = await storage.carregarLivros();

    final index = livros.indexWhere(
      (b) => b.titulo == widget.book.titulo && b.autor == widget.book.autor,
    );

    if (index != -1) {
      livros[index] = widget.book;
      await storage.salvarLivros(livros);
    }
    FirestoreService().atualizarProgresso(
      livroId: widget.book.id,
      progresso: paginaAtual,
      pontos: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(widget.book.titulo)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    widget.book.conteudo,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isSpeaking ? stop : speak,
                icon: Icon(isSpeaking ? Icons.stop : Icons.play_arrow),
                label: Text(isSpeaking ? 'Parar' : 'Ouvir'),
              ),
              ElevatedButton.icon(
                onPressed: gerarResumo,
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Gerar resumo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
