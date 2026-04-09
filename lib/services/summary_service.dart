import 'dart:convert';
import 'package:http/http.dart' as http;

class SummaryService {
  final String apiKey = "AIzaSyAQoUUmjpDjwmQIVPNzJeYtdtoIAeNt3OU";


  // 🔹 dividir texto
  List<String> dividirTexto(String texto, int tamanhoMax) {
    List<String> partes = [];

    for (int i = 0; i < texto.length; i += tamanhoMax) {
      partes.add(
        texto.substring(
          i,
          i + tamanhoMax > texto.length ? texto.length : i + tamanhoMax,
        ),
      );
    }

    return partes;
  }

  // 🔹 chamada Gemini
  Future<String> resumirParte(String texto, double percentual) async {
    final url =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Resuma o texto abaixo em aproximadamente ${(percentual * 100).toInt()}% do tamanho:\n\n$texto"
              }
            ]
          }
        ]
      }),
    );
    
    print("RESPOSTA API: ${response.body}");

    final data = jsonDecode(response.body);

    if (data == null|| data['candidates'] == null) {
      throw Exception("Resposta inválida da API: ${response.body}");
    }

    final content = data['candidates'][0]['content'];

    if (content == null || content['parts'] == null) {
      throw Exception("Nenhum resultado retornou");
    }

    return content['parts'][0]['text'];
  }

  // 🔹 resumo completo
  Future<String> gerarResumo(String conteudo, double percentual) async {
    final partes = dividirTexto(conteudo, 4000);

    List<String> resumos = [];

    for (var parte in partes) {
      final resumo = await resumirParte(parte, percentual);
      await Future.delayed(const Duration(milliseconds: 300));
      resumos.add(resumo);
    }

    return resumos.join("\n\n");
  }
}