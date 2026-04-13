import 'package:flutter/material.dart';
import 'package:neolivra/theme/app_theme.dart';
import '../models/book.dart';

class BookMetadataScreen extends StatefulWidget {
  final String content;

  const BookMetadataScreen({super.key, required this.content});

  @override
  State<BookMetadataScreen> createState() => _BookMetadataScreenState();
}

class _BookMetadataScreenState extends State<BookMetadataScreen> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  String? categoriaSelecionada;

  void salvar() {
    if (titleController.text.isEmpty || authorController.text.isEmpty) return;

    final book = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titleController.text,
      autor: authorController.text,
      conteudo: widget.content,
    );

    Navigator.pop(context, book);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Scaffold(
        appBar: AppBar(title: const Text("Dados do Livro")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: "Autor"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: salvar, child: const Text("Salvar")),
            ],
          ),
        ),
      ),
    );
  }
}
