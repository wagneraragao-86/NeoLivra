import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/App_Background.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();
  final userService = UserService();

  void login() async {
    try {
      await auth.login(emailController.text, passwordController.text);

      print("USUÁRIO CRIADO COM SUCESSO");

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Erro login: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erro: $e")));
    }
  }

  void register() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      final user = await auth.register(email, password);

      if (user != null) {
        await userService.createUser(uid: user.uid, email: email);
        print("Usuário criado com sucesso!");
      }
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          print("Email já cadastrado, tentando login...");

          await auth.login(emailController.text, passwordController.text);

          Navigator.pushReplacementNamed(context, '/home');
          return;
        }
      }

      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Senha'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: Text("Entrar")),
              ElevatedButton(onPressed: register, child: Text("Criar conta")),
            ],
          ),
        ),
      ),
    );
  }
}
