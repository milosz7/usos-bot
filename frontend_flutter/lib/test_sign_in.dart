import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'src/sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

const List<String> scopes = <String>[
  'email',
  'OpenID',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId:
      "1058611354127-f8ljjnolha571bckj6s36g1ubiln6h1v.apps.googleusercontent.com",
  scopes: scopes,
);

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GoogleSignInAccount? _currentUser;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });

    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _storeCredentials() async {
    try {
      final GoogleSignInAuthentication? authentication =
          await _currentUser?.authentication;
      var accessToken = authentication?.accessToken;
      var idtoken = authentication?.idToken;

      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'idToken', value: idtoken);

      print("Credential stored!");
    } catch (e) {
      print("Error signing in with Google: $e");
    }
  }

  Future<bool> _autoLogin() async {
    try {
      String? accessToken = await _storage.read(key: 'accessToken');
      String? idToken = await _storage.read(key: 'idToken');

      print("accessToken: $accessToken");
      print("idToken: $idToken");

      if (idToken != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      return false; // No valid credentials found
    } catch (e) {
      print("Auto-login failed: $e");
      return false;
    }
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
    if (user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: user,
            ),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: _storeCredentials,
              child: const Text("Store Credentials"))
        ],
      );
    } else {
      return Column(children: [
        buildSignInButton(
          onPressed: _handleSignIn,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: _autoLogin,
            child: const Text("AutoLogin")),
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
