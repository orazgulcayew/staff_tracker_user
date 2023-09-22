import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../main.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giriş"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Maglumatlaryňyzy giriziň:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const Gap(20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "arslanamanow@gmail.com",
                    label: Text('E-poçta')),
              ),
              const Gap(12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '',
                  label: Text('Açar sözi'),
                ),
              ),
              const Gap(12),
              const Text('Hasabyňyz ýokmy?'),
              TextButton(child: const Text('Hasap döret'), onPressed: () {}),
              const Gap(48),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          handleAuthentication();
                        },
                  child: Visibility(
                      visible: !isLoading,
                      replacement: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      child: const Text("Tassykla")),
                ),
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  void handleAuthentication() async {
    if (validated()) {
      try {
        await register();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maglumatlary doly giriziň"),
        ),
      );
    }
  }

  bool validated() {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  Future<void> register() async {
    try {
      setState(() {
        isLoading = true;
      });
      await auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false;
      });

      openHome();
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
      throw Exception(e.message);
    }
  }

  void openHome() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false);
  }
}
