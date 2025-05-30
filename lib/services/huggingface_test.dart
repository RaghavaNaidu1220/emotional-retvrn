import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceTest {
  static Future<bool> testToken() async {
    final token = dotenv.env['HUGGINGFACE_API_KEY'];
    
    if (token == null || token.isEmpty) {
      debugPrint('❌ No Hugging Face token found in .env file');
      return false;
    }

    try {
      debugPrint('🧪 Testing Hugging Face token...');
      
      // Test with a simple text-to-text model first
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/gpt2'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'inputs': 'Hello world',
          'options': {'wait_for_model': true}
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Hugging Face token is valid and has correct permissions');
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('❌ Token is invalid or expired');
        return false;
      } else if (response.statusCode == 403) {
        debugPrint('❌ Token lacks required permissions');
        return false;
      } else {
        debugPrint('⚠️ Unexpected response: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error testing token: $e');
      return false;
    }
  }

  static Future<bool> testWhisperModel() async {
    final token = dotenv.env['HUGGINGFACE_API_KEY'];
    
    if (token == null || token.isEmpty) {
      debugPrint('❌ No Hugging Face token found');
      return false;
    }

    try {
      debugPrint('🎤 Testing Whisper model access...');
      
      // Check if we can access the Whisper model
      final response = await http.get(
        Uri.parse('https://api-inference.huggingface.co/models/openai/whisper-large-v3'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Whisper model status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Whisper model is accessible');
        return true;
      } else if (response.statusCode == 401) {
        debugPrint('❌ Token cannot access Whisper model');
        return false;
      } else if (response.statusCode == 403) {
        debugPrint('❌ Token lacks permissions for Whisper model');
        return false;
      } else {
        debugPrint('⚠️ Whisper model response: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error testing Whisper model: $e');
      return false;
    }
  }
}
