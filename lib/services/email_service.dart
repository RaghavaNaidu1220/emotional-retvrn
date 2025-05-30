import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class EmailService {
  static Future<void> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: to,
      query: _encodeQueryParameters(<String, String>{
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      rethrow;
    }
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
