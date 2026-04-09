import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> loginAnonimo() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  User? get usuarioAtual => _auth.currentUser;
}