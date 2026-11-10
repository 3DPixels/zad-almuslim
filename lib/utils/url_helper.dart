import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  /// Launches a standard web URL.
  /// Opens the native app if installed, otherwise opens the web browser.
  static Future<void> launchWebUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  /// Launches the device's default email client safely.
  static Future<void> launchEmail({
    required String emailAddress,
    String? subject,
    String? body,
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      // Using a custom encoder is recommended by the url_launcher package
      // to ensure spaces in subjects/bodies are formatted correctly as %20
      // instead of + signs which some email clients misinterpret.
      query: _encodeQueryParameters(<String, String>{
        'subject': ?subject,
        'body': ?body,
      }),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw Exception('Could not launch email to $emailAddress');
    }
  }

  // Helper method for safely encoding email subjects and bodies
  static String? _encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return null;
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
