import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // for Firebase Authentication

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Log in
  Future<UserCredential> signIn(String email, String password) async {
    try {
      // Trim whitespaces and validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // More detailed error handling
      switch (e.code) {
        case 'invalid-credential':
          throw Exception('Invalid email or password');
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Incorrect password');
        default:
          throw Exception(e.message ?? 'Login failed');
      }
    }
  }

  // Sign up
  Future<UserCredential> signUp(String email, password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseFirestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  Future<void> deleteUser(BuildContext context) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Show a dialog to ask for the password
    String password = await _showPasswordDialog(context);

    if (password.isEmpty) {
      // If the password is empty, exit
      return;
    }

    // Reauthenticate the user with the entered password
    AuthCredential credential = EmailAuthProvider.credential(
      email: currentUser!.email!,
      password: password,
    );

    // Reauthenticate with the credentials
    await currentUser.reauthenticateWithCredential(credential);

    String uid = currentUser.uid;

    // Delete the user and their data
    await _auth.currentUser!.delete().then((v) async {
      // Also delete the user's data from Firestore
      await FirebaseFirestore.instance.collection('Users').doc(uid).delete();
    });
  }

  // Show a dialog to ask for the password
  Future<String> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();

    // Show the dialog and wait for the result
    String? password = await showDialog<String>(
      context: context,
      barrierDismissible: false, // Make it non-dismissible by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(hintText: "Password"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Dismiss the dialog and return the password
                Navigator.of(context).pop(passwordController.text.trim());
              },
              child: Text("OK"),
            ),
            TextButton(
              onPressed: () {
                // Dismiss the dialog without returning anything
                Navigator.of(context).pop('');
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );

    // If the password is null, return an empty string
    return password ?? '';
  }
}
