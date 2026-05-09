import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:neolivra/theme/app_Background.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

import '../models/book.dart';
import '../services/firestore_service.dart';
import '../utils/text_decoder.dart';
import 'book_metadata_screen.dart';
import 'reader_screen.dart';
import 'stats_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Future<void> importarLivro() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'epub'],
      withData: true,
    );

    if (result == null) return;

    final file = result.files.single;
    final nome = file.name.toLowerCase();

    String conteudo = '';

    try {
      // TXT
      if (nome.endsWith('.txt')) {
        conteudo = await TextDecoder.decode(file.bytes!);
      }
      // PDF (WEB)
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
      // EPUB
      else if (nome.endsWith('.epub')) {
        conteudo = await _extrairTextoEpub(file.bytes!);
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

  Future<String> _extrairTextoEpub(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    final containerXml = _readArchiveText(
      archive,
      'META-INF/container.xml',
    );

    if (containerXml == null) {
      throw Exception('Arquivo EPUB inválido: container ausente.');
    }

    final container = XmlDocument.parse(containerXml);
    final rootfile = container
        .findAllElements('rootfile')
        .cast<XmlElement>()
        .map((element) => element.getAttribute('full-path'))
        .whereType<String>()
        .firstOrNull;

    if (rootfile == null) {
      throw Exception('Arquivo EPUB inválido: OPF não encontrado.');
    }

    final opfXml = _readArchiveText(archive, rootfile);
    if (opfXml == null) {
      throw Exception('Arquivo EPUB inválido: manifesto ausente.');
    }

    final opf = XmlDocument.parse(opfXml);
    final manifest = <String, String>{};

    for (final item in opf.findAllElements('item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifest[id] = href;
      }
    }

    final spineIds = opf
        .findAllElements('itemref')
        .map((element) => element.getAttribute('idref'))
        .whereType<String>()
        .toList();

    final basePath = rootfile.contains('/')
        ? rootfile.substring(0, rootfile.lastIndexOf('/') + 1)
        : '';

    final buffer = StringBuffer();

    for (final id in spineIds) {
      final href = manifest[id];
      if (href == null) {
        continue;
      }

      final fullPath = _resolveZipPath(basePath, href);
      final chapter = _readArchiveText(archive, fullPath);
      if (chapter == null) {
        continue;
      }

      final text = _stripHtml(chapter).trim();
      if (text.isNotEmpty) {
        buffer.writeln(text);
        buffer.writeln();
      }
    }

    final conteudo = buffer.toString().trim();
    if (conteudo.isEmpty) {
      throw Exception('Não foi possível extrair texto do EPUB.');
    }

    return conteudo;
  }

  String? _readArchiveText(Archive archive, String path) {
    for (final file in archive.files) {
      if (file.name == path) {
        final content = file.content;
        if (content is List<int>) {
          return _decodeBytes(content);
        }
        if (content is String) {
          return content;
        }
      }
    }

    return null;
  }

  String _decodeBytes(List<int> bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  String _resolveZipPath(String basePath, String relativePath) {
    final resolved = Uri.parse(basePath).resolve(relativePath).path;
    return resolved.startsWith('/') ? resolved.substring(1) : resolved;
  }

  String _stripHtml(String input) {
    final withoutScripts = input
        .replaceAll(RegExp(r'(?is)<script[^>]*>.*?</script>'), ' ')
        .replaceAll(RegExp(r'(?is)<style[^>]*>.*?</style>'), ' ');
    final text = withoutScripts.replaceAll(RegExp(r'<[^>]+>'), ' ');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void abrirLivro(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
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

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    for (final item in this) {
      return item;
    }
    return null;
  }
}
