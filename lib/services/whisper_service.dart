import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';

class WhisperService {
  static final WhisperService _instance = WhisperService._internal();
  factory WhisperService() => _instance;
  WhisperService._internal();

  // Use direct API keys from config
  String get _openaiKey => AppConfig.openAIApiKey;
  String get _hfKey => AppConfig.huggingFaceApiKey;

  bool get isAvailable => _openaiKey.isNotEmpty || _hfKey.isNotEmpty;

  void initialize() {
    debugPrint('Whisper service initialized with direct API keys');
    debugPrint('OpenAI available: ${_openaiKey.isNotEmpty}');
    debugPrint('HuggingFace available: ${_hfKey.isNotEmpty}');
  }

  Future<String> transcribeAudio(Uint8List audioData, {
    String format = 'webm',
    String language = 'en',
  }) async {
    if (!isAvailable) {
      throw Exception('No Whisper API keys configured');
    }

    // Try Hugging Face first (free)
    if (_hfKey.isNotEmpty) {
      try {
        return await _transcribeWithHuggingFace(audioData);
      } catch (e) {
        debugPrint('Hugging Face Whisper failed: $e');
        // Fall back to OpenAI if available
        if (_openaiKey.isNotEmpty) {
          return await _transcribeWithOpenAI(audioData, format: format, language: language);
        }
        rethrow;
      }
    }

    // Use OpenAI if Hugging Face not available
    if (_openaiKey.isNotEmpty) {
      return await _transcribeWithOpenAI(audioData, format: format, language: language);
    }

    throw Exception('No valid API keys available');
  }

  Future<String> _transcribeWithHuggingFace(Uint8List audioData) async {
    debugPrint('Transcribing with Hugging Face Whisper...');
    
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/openai/whisper-large-v3'),
      headers: {
        'Authorization': 'Bearer $_hfKey',
        'Content-Type': 'audio/wav',
      },
      body: audioData,
    );

    debugPrint('HF Response status: ${response.statusCode}');
    debugPrint('HF Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is Map && data.containsKey('text')) {
        return (data['text'] as String).trim();
      } else if (data is List && data.isNotEmpty && data[0] is Map) {
        return (data[0]['text'] as String).trim();
      } else {
        throw Exception('Unexpected response format from Hugging Face');
      }
    } else if (response.statusCode == 503) {
      throw Exception('Model is loading, please try again in a few seconds');
    } else {
      throw Exception('Hugging Face Whisper API error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _transcribeWithOpenAI(Uint8List audioData, {
    String format = 'webm',
    String language = 'en',
  }) async {
    debugPrint('Transcribing with OpenAI Whisper...');
    
    final request = http.MultipartRequest(
      'POST', 
      Uri.parse('https://api.openai.com/v1/audio/transcriptions')
    );
    
    request.headers.addAll({
      'Authorization': 'Bearer $_openaiKey',
    });

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        audioData,
        filename: 'audio.$format',
      ),
    );

    request.fields.addAll({
      'model': 'whisper-1',
      'language': language,
      'response_format': 'json',
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('OpenAI Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['text'] as String).trim();
    } else {
      throw Exception('OpenAI Whisper API error: ${response.statusCode} - ${response.body}');
    }
  }

  // Test method for Hugging Face token
  Future<bool> testHuggingFaceToken() async {
    if (_hfKey.isEmpty) {
      debugPrint('No Hugging Face token available');
      return false;
    }

    try {
      debugPrint('Testing Hugging Face token...');
      final response = await http.get(
        Uri.parse('https://api-inference.huggingface.co/models/openai/whisper-large-v3'),
        headers: {
          'Authorization': 'Bearer $_hfKey',
        },
      );

      debugPrint('Token test response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 503; // 503 means model is loading
    } catch (e) {
      debugPrint('Token test failed: $e');
      return false;
    }
  }
}
