import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final userService = UserService();

  final nameController = TextEditingController();

  bool loading = true;
  String? photoUrl;
  File? imageFile;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final doc = await userService.getUser(user.uid);

    if (doc.exists) {
      nameController.text = doc['name'] ?? '';
      photoUrl = doc['photoUrl'];
    }

    setState(() => loading = false);
  }

  Future<void> saveName() async {
    await userService.updateName(user.uid, nameController.text);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nome atualizado')));
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });

      await uploadImage();
    }
  }

  Future<void> uploadImage() async {
    if (imageFile == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_photos')
        .child('${user.uid}.jpg');

    await ref.putFile(imageFile!);

    final url = await ref.getDownloadURL();

    await userService.updatePhoto(user.uid, url);

    setState(() {
      photoUrl = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 👤 Avatar
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 45,
                backgroundImage: imageFile != null
                    ? FileImage(imageFile!)
                    : (photoUrl != null && photoUrl!.isNotEmpty
                              ? NetworkImage(photoUrl!)
                              : null)
                          as ImageProvider?,
                child: (photoUrl == null && imageFile == null)
                    ? Text(
                        user.email![0].toUpperCase(),
                        style: const TextStyle(fontSize: 30),
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // 📧 Email
            Text(user.email!, style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            // ✏️ Nome
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: saveName, child: const Text('Salvar')),

            const Spacer(),

            // 🚪 Logout
            ElevatedButton(
              onPressed: () async {
                await AuthService().logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      ),
    );
  }
}
