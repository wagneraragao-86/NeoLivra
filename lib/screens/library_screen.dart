import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  return Scaffold(
    appBar: AppBar(
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
    body: StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().listarLivros(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Nenhum livro encontrado"));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final livro = docs[index];

            return ListTile(
              title: Text(livro['titulo'] ?? 'Sem título'),
              subtitle: Text(livro['autor'] ?? 'Sem Autor'),
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
              );
            },
          );
        },
      ),
    );
  }
}