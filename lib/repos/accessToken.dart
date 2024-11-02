import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';

class AccessFirebaseToken {
  static String fMessagingScope =
      "https://www.googleapis.com/auth/firebase.messaging";

  Future<String> getAccessToken() async {
    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": dotenv.env['PROJECT_ID']!,
        "private_key_id": dotenv.env['PRIVATE_KEY_ID']!,
        "private_key": dotenv.env['PRIVATE_KEY']!,
        "client_email": dotenv.env['CLIENT_EMAIL']!,
        "client_id": dotenv.env['CLIENT_ID']!,
        "auth_uri": dotenv.env['AUTH_URI']!,
        "token_uri": dotenv.env['TOKEN_URI']!,
        "auth_provider_x509_cert_url": dotenv.env['AUTH_PROVIDER_CERT_URL']!,
        "client_x509_cert_url": dotenv.env['CLIENT_CERT_URL']!,
        "universe_domain": dotenv.env['UNIVERSE_DOMAIN'] ?? "googleapis.com",
      }),
      [fMessagingScope],
    );

    final accessToken = client.credentials.accessToken.data;
    return accessToken;
  }
}
