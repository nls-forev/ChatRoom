import 'package:demodb/services/auth/auth_service.dart';
import 'package:demodb/components/my_button.dart';
import 'package:demodb/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cfpasswordController = TextEditingController();

  final void Function()? onTap;

  void register(BuildContext context) {
    if (_passwordController.text == _cfpasswordController.text) {
      try {
        AuthService().signUp(_emailController.text, _emailController.text);
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Passwords don't match!"),
        ),
      );
    }
  }

  RegisterPage({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust layout when keyboard pops up
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        // Makes the content scrollable
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).size.height * 0.1), // Top spacing
              Icon(Icons.message,
                  size: 60, color: Theme.of(context).colorScheme.primary),
              const SizedBox(
                height: 50,
              ),
              Text(
                "Let's create an account for you",
                style: TextStyle(
                    fontSize: 16, color: Theme.of(context).colorScheme.primary),
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
              MyTextField(
                hintText: "Confirm password",
                isPass: true,
                controller: _cfpasswordController,
              ),
              const SizedBox(
                height: 10,
              ),
              MyButton(
                text: "Register",
                onTap: () => register(context),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(
                      "Login now",
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
    );
  }
}
