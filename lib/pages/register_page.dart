import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:staff_tracker_user/main.dart';
import 'package:staff_tracker_user/pages/login_page.dart';

import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hasap döret"),
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
                controller: nameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Arslan Amanow",
                    label: Text('At we familiýa')),
              ),
              const Gap(12),
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
              const Text('Eýýäm hasabyňyz barmy?'),
              TextButton(
                  child: const Text('Giriş'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ));
                  }),
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
        nameController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  Future<void> register() async {
    try {
      setState(() {
        isLoading = true;
      });
      await auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;

      try {
        await user?.updateDisplayName(nameController.text);
        await user?.reload();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .set({
          'name': nameController.text,
          'uid': user?.uid,
          'email': emailController.text,
          'password': passwordController.text
        });
      } on FirebaseException catch (e) {
        debugPrint('Error updating user profile: $e');
        throw Exception(e.message);
      }

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
