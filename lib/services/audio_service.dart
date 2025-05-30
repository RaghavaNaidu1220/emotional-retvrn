import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:async';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _transcribedText;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  // Web Speech Recognition
  dynamic _speechRecognition;
  bool _isListening = false;
  Completer<String?>? _speechCompleter;
  String _debugInfo = '';

  // Text-to-Speech
  dynamic _speechSynthesis;
  bool _isSpeaking = false;
  bool _ttsEnabled = true;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  String? get transcribedText => _transcribedText;
  String? get currentRecordingPath => null;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String get debugInfo => _debugInfo;

  bool get isSpeaking => _isSpeaking;
  bool get ttsEnabled => _ttsEnabled;

  // Check if speech recognition is supported
  bool isSpeechRecognitionSupported() {
    return js.context.hasProperty('webkitSpeechRecognition') || 
           js.context.hasProperty('SpeechRecognition');
  }

  // Get current interim results while recording
  String getCurrentTranscript() {
    return _transcribedText ?? '';
  }

  // For web, we'll use speech recognition directly
  Future<bool> requestPermissions() async {
    try {
      // Request microphone permission
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'audio': true,
      });
      
      if (stream != null) {
        // Stop the stream immediately after checking permission
        stream.getTracks().forEach((track) => track.stop());
        debugPrint('Microphone permission granted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Microphone permission denied: $e');
      return false;
    }
  }

  // Initialize speech recognition for web
  bool _initializeSpeechRecognition() {
    try {
      _debugInfo = 'Initializing speech recognition...';
      
      // Check if speech recognition is supported
      if (js.context.hasProperty('webkitSpeechRecognition')) {
        _speechRecognition = js.JsObject(js.context['webkitSpeechRecognition']);
        _debugInfo += '\nUsing webkitSpeechRecognition';
      } else if (js.context.hasProperty('SpeechRecognition')) {
        _speechRecognition = js.JsObject(js.context['SpeechRecognition']);
        _debugInfo += '\nUsing SpeechRecognition';
      } else {
        _debugInfo += '\nSpeech recognition not supported';
        debugPrint('Speech recognition not supported in this browser');
        return false;
      }
      
      // Configure speech recognition
      _speechRecognition['continuous'] = false;
      _speechRecognition['interimResults'] = false;
      _speechRecognition['lang'] = 'en-US';
      _speechRecognition['maxAlternatives'] = 1;
      
      _debugInfo += '\nConfiguration set';
      
      // Set up event handlers with better error handling
      _speechRecognition['onstart'] = js.allowInterop(() {
        _debugInfo += '\nSpeech recognition started successfully';
        debugPrint('Speech recognition started');
        _isListening = true;
        _transcribedText = '';
      });
      
      _speechRecognition['onresult'] = js.allowInterop((event) {
        _debugInfo += '\nResult received';
        debugPrint('Speech recognition result received');
        try {
          // Simple approach - just get the transcript directly
          final transcript = js.context.callMethod('eval', [
            '(function(e) { try { return e.results[e.results.length-1][0].transcript; } catch(err) { return ""; } })(arguments[0])'
          ]);
          
          if (transcript != null && transcript.toString().trim().isNotEmpty) {
            _transcribedText = transcript.toString().trim();
            _debugInfo += '\nTranscript captured: "$_transcribedText"';
            debugPrint('Transcript captured: "$_transcribedText"');
            
            if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
              _speechCompleter!.complete(_transcribedText);
            }
          } else {
            debugPrint('No transcript found in result');
          }
        } catch (e) {
          _debugInfo += '\nError processing result: $e';
          debugPrint('Error processing speech result: $e');
        }
      });
      
      _speechRecognition['onerror'] = js.allowInterop((event) {
        final error = event['error'];
        _debugInfo += '\nError: $error';
        debugPrint('Speech recognition error: $error');
        
        _isListening = false;
        _isRecording = false;
        
        if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
          _speechCompleter!.completeError('Speech recognition error: $error');
        }
      });
      
      _speechRecognition['onend'] = js.allowInterop(() {
        _debugInfo += '\nSpeech recognition ended';
        debugPrint('Speech recognition ended');
        _isListening = false;
        _isRecording = false;
        
        if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
          _speechCompleter!.complete(_transcribedText ?? '');
        }
      });
      
      _debugInfo += '\nEvent handlers set up';
      return true;
    } catch (e) {
      _debugInfo += '\nInitialization error: $e';
      debugPrint('Error initializing speech recognition: $e');
      return false;
    }
  }

  // Recording methods
  Future<String?> startRecording() async {
    try {
      _debugInfo = 'Starting recording process...';
      debugPrint('Starting speech recognition...');
      
      // Request microphone permission first
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw Exception('Microphone permission denied. Please allow microphone access and try again.');
      }
      
      if (!_initializeSpeechRecognition()) {
        throw Exception('Speech recognition not supported in this browser. Please use Chrome or Edge.');
      }
      
      _isRecording = true;
      _transcribedText = '';
      _speechCompleter = Completer<String?>();
      
      _debugInfo += '\nCalling start method...';
      
      // Start speech recognition
      _speechRecognition.callMethod('start');
      
      _debugInfo += '\nStart method called successfully';
      
      return null;
    } catch (e) {
      _debugInfo += '\nStart error: $e';
      debugPrint('Error starting recording: $e');
      _isRecording = false;
      throw Exception('Failed to start speech recognition: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      _debugInfo += '\nStopping recording...';
      debugPrint('Stopping speech recognition...');
      
      if (_speechRecognition != null && _isListening) {
        _speechRecognition.callMethod('stop');
        _debugInfo += '\nStop method called';
      }
      
      _isRecording = false;
      
      // Wait for final results with shorter timeout
      if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
        try {
          await _speechCompleter!.future.timeout(const Duration(seconds: 2));
        } catch (e) {
          _debugInfo += '\nTimeout waiting for results: $e';
          debugPrint('Timeout waiting for speech recognition result: $e');
          if (!_speechCompleter!.isCompleted) {
            final result = _transcribedText ?? '';
            _speechCompleter!.complete(result.trim());
          }
        }
      }
      
    } catch (e) {
      _debugInfo += '\nStop error: $e';
      debugPrint('Error stopping recording: $e');
      _isRecording = false;
    }
  }

  // Audio playback methods
  Future<void> play(String audioUrl) async {
    try {
      debugPrint('Playing audio: $audioUrl');
      _isPlaying = true;
      _totalDuration = const Duration(minutes: 10);
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> playAudio(String url) async {
    await play(url);
  }

  Future<void> pause() async {
    try {
      _isPlaying = false;
      debugPrint('Audio paused');
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  Future<void> stop() async {
    try {
      _isPlaying = false;
      _currentPosition = Duration.zero;
      debugPrint('Audio stopped');
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<void> stopAudio() async {
    await stop();
  }

  Future<void> seek(Duration position) async {
    try {
      _currentPosition = position;
      debugPrint('Seeking to: ${position.inSeconds}s');
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<String?> speechToText() async {
    try {
      debugPrint('Starting speech to text...');
      
      await startRecording();
      
      // Wait for user to speak
      await Future.delayed(const Duration(seconds: 5));
      
      await stopRecording();
      
      return _transcribedText;
    } catch (e) {
      debugPrint('Error in speech to text: $e');
      return null;
    }
  }

  // Text-to-Speech methods
  Future<void> speak(String text, {String? language, double rate = 1.0, double pitch = 1.0}) async {
    if (!_ttsEnabled || text.trim().isEmpty) return;
    
    try {
      if (js.context.hasProperty('speechSynthesis')) {
        _speechSynthesis = js.context['speechSynthesis'];
      } else {
        debugPrint('Text-to-speech not supported in this browser');
        return;
      }
      
      // Stop any current speech
      await stopSpeaking();
      
      _isSpeaking = true;
      
      // Create speech utterance
      final utterance = js.JsObject(js.context['SpeechSynthesisUtterance'], [text]);
      
      // Configure utterance
      utterance['lang'] = language ?? 'en-US';
      utterance['rate'] = rate;
      utterance['pitch'] = pitch;
      utterance['volume'] = 0.8;
      
      // Fix the event handlers in the speak method
      utterance['onstart'] = js.allowInterop((event) {
        debugPrint('Started speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
        _isSpeaking = true;
      });

      utterance['onend'] = js.allowInterop((event) {
        debugPrint('Finished speaking');
        _isSpeaking = false;
      });

      utterance['onerror'] = js.allowInterop((event) {
        try {
          final error = event != null && event.hasProperty('error') ? event['error'] : 'Unknown error';
          debugPrint('Speech synthesis error: $error');
        } catch (e) {
          debugPrint('Speech synthesis error (could not parse): $e');
        }
        _isSpeaking = false;
      });
      
      // Start speaking
      _speechSynthesis.callMethod('speak', [utterance]);
      
    } catch (e) {
      debugPrint('Error in text-to-speech: $e');
      _isSpeaking = false;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      if (_speechSynthesis != null && _isSpeaking) {
        _speechSynthesis.callMethod('cancel');
        _isSpeaking = false;
        debugPrint('Speech synthesis stopped');
      }
    } catch (e) {
      debugPrint('Error stopping speech synthesis: $e');
    }
  }

  void toggleTTS() {
    _ttsEnabled = !_ttsEnabled;
    debugPrint('TTS ${_ttsEnabled ? 'enabled' : 'disabled'}');
    
    if (!_ttsEnabled) {
      stopSpeaking();
    }
  }

  void setTTSEnabled(bool enabled) {
    _ttsEnabled = enabled;
    if (!enabled) {
      stopSpeaking();
    }
  }

  // Get available voices
  List<String> getAvailableVoices() {
    try {
      if (_speechSynthesis != null) {
        final voices = _speechSynthesis.callMethod('getVoices');
        if (voices != null) {
          final voiceList = <String>[];
          for (int i = 0; i < voices['length']; i++) {
            final voice = voices[i];
            voiceList.add('${voice['name']} (${voice['lang']})');
          }
          return voiceList;
        }
      }
    } catch (e) {
      debugPrint('Error getting voices: $e');
    }
    return [];
  }

  void dispose() {
    // Stop speech synthesis
    if (_speechSynthesis != null && _isSpeaking) {
      try {
        _speechSynthesis.callMethod('cancel');
      } catch (e) {
        debugPrint('Error stopping speech synthesis on dispose: $e');
      }
    }
    
    // Stop speech recognition
    if (_speechRecognition != null && _isListening) {
      try {
        _speechRecognition.callMethod('stop');
      } catch (e) {
        debugPrint('Error stopping speech recognition on dispose: $e');
      }
    }
    
    _isRecording = false;
    _isPlaying = false;
    _isSpeaking = false;
    _transcribedText = null;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _isListening = false;
    
    if (_speechCompleter != null && !_speechCompleter!.isCompleted) {
      _speechCompleter!.complete('');
    }
  }
}
