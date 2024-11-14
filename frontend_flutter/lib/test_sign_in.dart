import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _handleSignIn() async {
    try {
      FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } catch (error) {
      print(error);
    }
  }

  Widget _loadImage(String url) {
    try {
      return Image.network(url);
    } catch (_) {
      return const Placeholder();
    }
  }

  Widget _buildBody() {
    final User? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: _loadImage(user.photoURL!),
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email!),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: _logout,
              child: const Text("logout")),
        ],
      );
    } else {
      return Column(children: [
        ElevatedButton(
          onPressed: _handleSignIn,
          child: const Text("Sign in"),
        ),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
}
