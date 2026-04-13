import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:neolivra/theme/app_theme.dart';
import '../models/book.dart';
import 'reader_screen.dart';
import 'book_metadata_screen.dart';
import '../utils/text_decoder.dart';
import 'stats_screen.dart';
import '../services/firestore_service.dart';
import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<void> importarLivro() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf'],
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;
    final nome = file.name.toLowerCase();

    String conteudo = '';

    try {
      // 📄 TXT
      if (nome.endsWith('.txt')) {
        conteudo = await TextDecoder.decode(file.bytes!);
      }
      // 📕 PDF (WEB)
      else if (nome.endsWith('.pdf')) {
        Uint8List bytes = file.bytes!;

        PdfDocument document = PdfDocument(inputBytes: bytes);
        String texto = '';

        for (int i = 0; i < document.pages.count; i++) {
          texto += PdfTextExtractor(document).extractText(startPageIndex: i);
        }

        document.dispose();
        conteudo = texto;
      }

      // tela de metadados
      final book = await Navigator.push<Book>(
        context,
        MaterialPageRoute(
          builder: (_) => BookMetadataScreen(content: conteudo),
        ),
      );

      if (book != null) {
        await FirestoreService().salvarLivro(
          titulo: book.titulo,
          autor: book.autor,
          conteudo: book.conteudo,
        );
      }
    } catch (e) {
      print("Erro ao importar arquivo: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Erro ao importar arquivo")));
    }
  }

  void abrirLivro(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Minha Biblioteca"),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => StatsScreen()),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: importarLivro,
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: StreamBuilder(
            stream: FirestoreService().listarLivros(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final livro = docs[index];

                  return _buildBookCard(livro);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(dynamic livro) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReaderScreen(
              book: Book(
                id: livro.id,
                titulo: livro['titulo'],
                autor: livro['autor'],
                conteudo: livro['conteudo'],
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book,
                color: Colors.greenAccent,
                size: 28,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    livro['titulo'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    livro['autor'],
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text("Nenhum livro ainda", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          const Text(
            "Toque no + para adicionar",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
