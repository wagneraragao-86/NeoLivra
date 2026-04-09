import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../config/settings_service.dart';
import 'package:flutter/foundation.dart';

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
      .where((v) =>
          v['locale'] != null &&
          v['locale'].toString().toLowerCase().contains('pt'))
      .toList();

  setState(() {
    voices = ptVoices;
  });
}

  void load() async {
    final data = await service.loadSettings();
    setState(() {
      speechRate = data["rate"];
      ignoreSuper = data["ignoreSuper"];
      ignoreSub = data["ignoreSub"];
      volume = data["volume"];
      selectedVoice = data["voice"] ?? 'default';
    });
  }

  void save() async {
    await service.saveSettings(
      speechRate,
      ignoreSuper,
      ignoreSub,
      volume,
      selectedVoice,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configurações salvas')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações de Leitura')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Velocidade da voz'),
            Slider(
              value: speechRate,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: speechRate.toString(),
              onChanged: (value) {
                setState(() => speechRate = value);
              },
            ),
            const Text('Volume da voz'),
            Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              label: volume.toString(),
              onChanged: (value) {
                setState(() => volume = value);
              },
            ),
            DropdownButtonFormField<String>(
              value: voices.any((v) => v['name'] == selectedVoice)
                  ? selectedVoice
                  : 'default',
              decoration: const InputDecoration(
                labelText: 'Tipo de voz',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: 'default',
                  child: Text('Padrão do sistema'),
                ),

                ...voices.map(
                  (voice) => DropdownMenuItem(
                    value: voice['name'],
                    child: Text("${voice['name']} (${voice['locale']})"),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedVoice = value!;
                });
              },
            ),
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
            const SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }
}
