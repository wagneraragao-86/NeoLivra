import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _auth = AuthService();

  String get userId => _auth.user!.uid;

  Future<void> salvarLivro({
    required String titulo,
    required String autor,
    required String conteudo,
  }) async {
    await _db
        .collection('usuarios')
        .doc(userId)
        .collection('livros')
        .add({
      'titulo': titulo,
      'autor': autor,
      'conteudo': conteudo,
      'progresso': 0,
      'pontuacao': 0,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> listarLivros() {
    return _db
        .collection('usuarios')
        .doc(userId)
        .collection('livros')
        .orderBy('criadoEm', descending: true)
        .snapshots();
  }

  Future<void> atualizarProgresso({
    required String livroId,
    required int progresso,
    required int pontos,
  }) async {
    await _db
        .collection('usuarios')
        .doc(userId)
        .collection('livros')
        .doc(livroId)
        .update({
      'progresso': progresso,
      'pontuacao': FieldValue.increment(pontos),
    });
  }
}