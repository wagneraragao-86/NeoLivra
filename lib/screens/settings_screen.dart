import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../config/settings_service.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../controllers/app_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final service = SettingsService();

  double speechRate = 0.5;
  double volume = 1.0;
  bool ignoreSuper = true;
  bool ignoreSub = true;
  List<Map<String, dynamic>> voices = [];
  String selectedVoice = 'default';
  bool isDarkMode = true;

  String getVoiceName(Map<String, dynamic> voice) {
    final name = voice['name'].toString().toLowerCase();

    if (name.contains('female')) return 'Feminina';
    if (name.contains('male')) return 'Masculina';

    return voice['name']; // fallback
  }

  @override
  void initState() {
    super.initState();
    load();
    loadVoices();
  }

  Future<void> loadVoices() async {
    final flutterTts = FlutterTts();

    dynamic data;

    try {
      data = await flutterTts.getVoices; // ← CORRETO
    } catch (e) {
      print("Erro ao buscar vozes: $e");
      return;
    }

    print("VOZES RAW: $data");

    if (data == null) return;

    final ptVoices = List<Map<String, dynamic>>.from(data)
        .where(
          (v) =>
              v['locale'] != null &&
              v['locale'].toString().toLowerCase().contains('pt'),
        )
        .toList();

    setState(() {
      voices = ptVoices;
    });
  }

  void load() async {
    final data = await service.loadSettings();
    final theme = await service.loadTheme();

    setState(() {
      speechRate = data["rate"];
      ignoreSuper = data["ignoreSuper"];
      ignoreSub = data["ignoreSub"];
      volume = data["volume"];
      selectedVoice = data["voice"] ?? 'default';
      isDarkMode = theme;
    });
  }

  void save() async {
    await service.saveSettings(
      speechRate,
      ignoreSuper,
      ignoreSub,
      volume,
      selectedVoice,
      isDarkMode,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configurações salvas')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Configurações')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              // 🔊 VELOCIDADE
              _buildCard(
                title: "Velocidade da voz",
                child: Column(
                  children: [
                    Slider(
                      value: speechRate,
                      min: 0.2,
                      max: 1.0,
                      divisions: 8,
                      label: speechRate.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() => speechRate = value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 🎚️ OPÇÕES
              _buildCard(
                title: "Leitura",
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Ignorar sobrescrito'),
                      value: ignoreSuper,
                      onChanged: (value) {
                        setState(() => ignoreSuper = value);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Ignorar subescrito'),
                      value: ignoreSub,
                      onChanged: (value) {
                        setState(() => ignoreSub = value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 🎨 TEMA
              _buildCard(
                title: "Tema",
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("Modo escuro"),
                      value: isDarkMode,
                      onChanged: (value) {
                        themeController.toggleTheme(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 💾 BOTÃO SALVAR
              ElevatedButton(
                onPressed: save,
                child: const Text('Salvar configurações'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.neonGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.softGreen.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 1,
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
