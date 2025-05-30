import 'package:flutter/foundation.dart';

class SimpleVoiceService {
  static final SimpleVoiceService _instance = SimpleVoiceService._internal();
  factory SimpleVoiceService() => _instance;
  SimpleVoiceService._internal();

  bool _isListening = false;
  String _transcript = '';

  bool get isListening => _isListening;
  String get transcript => _transcript;

  Future<bool> initialize() async {
    try {
      debugPrint('Simple voice service initialized');
      return true;
    } catch (e) {
      debugPrint('Error initializing voice service: $e');
      return false;
    }
  }

  Future<void> startListening() async {
    try {
      _isListening = true;
      _transcript = '';
      debugPrint('Started listening (simulated)');
    } catch (e) {
      debugPrint('Error starting listening: $e');
      _isListening = false;
    }
  }

  Future<void> stopListening() async {
    try {
      _isListening = false;
      // Simulate transcription
      _transcript = "I'm feeling reflective today and wanted to share my thoughts about my emotional journey.";
      debugPrint('Stopped listening, transcript: $_transcript');
    } catch (e) {
      debugPrint('Error stopping listening: $e');
    }
  }

  void dispose() {
    _isListening = false;
    _transcript = '';
  }
}
