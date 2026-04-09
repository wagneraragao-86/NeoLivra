import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class LibraryStorage {
  static const _key = "neolivra_library";

  Future<void> salvarLivros(List<Book> livros) async {
    final prefs = await SharedPreferences.getInstance();
    
    final jsonList = livros.map((b) => b.toJson()).toList();
    prefs.setString(_key, jsonEncode(jsonList));
  }

  Future<List<Book>> carregarLivros() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);

    if (data == null) return [];

    final List decoded = jsonDecode(data);
    return decoded.map((e) => Book.fromJson(e, e['id'])).toList();
  }
}