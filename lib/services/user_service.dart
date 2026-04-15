import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  Future<void> createUser({
    required String uid,
    required String email,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'nome': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<void> updateName(String uid, String name) {
    return _db.collection('users').doc(uid).update({
      'name': name,
    });
  }

  Future<void> updatePhoto(String uid, String photoUrl) async {
    await _db.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
    });
  }
}