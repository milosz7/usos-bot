import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:http/http.dart' as http;

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

  Future<void> _handleGetToken() async {
    try {
      var idToken = await _currentUser!.getIdToken(true);
      print(idToken);
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleTestAuth() async {
    try {
      var idToken = await _currentUser!.getIdToken(true);
      const String url = "http://localhost:8000/auth/test";

      final response = await http.get(Uri.parse(url), headers: {
        "Authorization": "Bearer $idToken",
      });

      if (response.statusCode == 200) {
        print('Response from server: ${response.body}');
      } else {
        print(
            'Failed to authenticate with server. Status: ${response.statusCode}');
      }
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
              onPressed: _handleGetToken,
              child: const Text("Get Token")),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: _handleTestAuth,
              child: const Text("Test Auth")),
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
