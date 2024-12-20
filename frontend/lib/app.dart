import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_flutter/styles.dart';
import 'test_sign_in.dart';
import 'full_app.dart';

class AppState extends ChangeNotifier {}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (BuildContext context) => AppState(),
      child: MaterialApp(
          title: "Usos Bot",
          theme: GlobalThemeData.defaultTheme,
          routes: {
            "/": (context) => const FullPage(),
            "/test": (context) => const SignIn(),
          }),
    );
  }
}
