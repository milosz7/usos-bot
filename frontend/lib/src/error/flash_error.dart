import 'package:flutter/material.dart';
import 'package:frontend_flutter/styles.dart';

class HttpResponseCodes {
  static int ok = 200;
  static int unauthorized = 401;
  static int notFound = 404;
  static int internalServerError = 500;
  static int serviceUnavailable = 503;
}

class FlashError {
  static Map<int, String> codeToMessage = {
    HttpResponseCodes.unauthorized: "Błąd autoryzacji.",
    HttpResponseCodes.notFound: "Nie znaleziono.",
    HttpResponseCodes.internalServerError: "Wewnętrzny błąd serwera.",
    HttpResponseCodes.serviceUnavailable: "Serwer niedostępny",
  };

  static String _buildErrorMessage(int statusCode) {
    return "${codeToMessage[statusCode]}, Kod błędu: $statusCode.";
  }

  static void showFlashError(BuildContext context, int statusCode) {
    final message = _buildErrorMessage(statusCode);

    ThemeData theme = Theme.of(context);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        elevation: ElevationSize.max,
        padding: const EdgeInsets.all(PaddingSize.large),
        content:
            Text(message, style: TextStyle(color: theme.colorScheme.onError)),
        leading: Icon(Icons.error, color: theme.colorScheme.onError),
        backgroundColor: theme.colorScheme.error,
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary),
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: Text(
              "Zamknij",
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
