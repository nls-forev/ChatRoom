import 'package:demodb/services/auth/auth_service.dart';
import 'package:demodb/components/my_button.dart';
import 'package:demodb/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final void Function()? onTap;

  void login(BuildContext context) async {
    try {
      await AuthService().signIn(
          _emailController.text.trim(), _passwordController.text.trim());
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Error'),
          content: Text(e.message ?? 'An unknown error occurred'),
        ),
      );
    }
  }

  LoginPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Allow layout to adjust for the keyboard
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SingleChildScrollView(
          // Make the content scrollable
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.1), // Add top spacing
                Icon(Icons.message,
                    size: 60, color: Theme.of(context).colorScheme.primary),
                const SizedBox(
                  height: 50,
                ),
                Text(
                  "Welcome back, you've been missed!",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(
                  height: 25,
                ),
                MyTextField(
                  hintText: "Email",
                  isPass: false,
                  controller: _emailController,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyTextField(
                  hintText: "Password",
                  isPass: true,
                  controller: _passwordController,
                ),
                const SizedBox(
                  height: 10,
                ),
                MyButton(
                  text: "Login",
                  onTap: () => login(context),
                ),
                const SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member? ",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        "Register now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
