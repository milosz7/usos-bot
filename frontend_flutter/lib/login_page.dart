import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:frontend_flutter/styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: theme.colorScheme.primary,
              shadowColor: theme.colorScheme.secondary,
              elevation: ElevationSize.medium,
              child: Padding(
                  padding: const EdgeInsets.all(PaddingSize.large),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            0, 0, 0, PaddingSize.medium),
                        child: SelectableText(
                          "Usos Bot",
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: FontSize.large,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      SignInButton(
                        Buttons.google,
                        onPressed: () => print("123"),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
