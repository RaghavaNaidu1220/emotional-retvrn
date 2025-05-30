import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class WebAudioRecorder {
  static final WebAudioRecorder _instance = WebAudioRecorder._internal();
  factory WebAudioRecorder() => _instance;
  WebAudioRecorder._internal();

  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  final List<html.Blob> _recordedChunks = [];
  bool _isRecording = false;
  Completer<Uint8List>? _recordingCompleter;

  bool get isRecording => _isRecording;

  Future<bool> requestPermissions() async {
    try {
      _mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
          'sampleRate': 16000,
        }
      });
      
      if (_mediaStream != null) {
        debugPrint('Microphone permission granted');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Microphone permission denied: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      if (_mediaStream == null) {
        final hasPermission = await requestPermissions();
        if (!hasPermission) {
          throw Exception('Microphone permission denied');
        }
      }

      _recordedChunks.clear();
      _recordingCompleter = Completer<Uint8List>();

      // Create MediaRecorder with WebM format
      _mediaRecorder = html.MediaRecorder(_mediaStream!, {
        'mimeType': 'audio/webm;codecs=opus'
      });

      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blobEvent = event as html.BlobEvent;
        if (blobEvent.data != null && blobEvent.data!.size > 0) {
          _recordedChunks.add(blobEvent.data!);
        }
      });

      _mediaRecorder!.addEventListener('stop', (event) async {
        debugPrint('Recording stopped, processing audio...');
        await _processRecordedAudio();
      });

      _mediaRecorder!.addEventListener('error', (event) {
        debugPrint('MediaRecorder error: $event');
        _isRecording = false;
        if (!_recordingCompleter!.isCompleted) {
          _recordingCompleter!.completeError('Recording error: $event');
        }
      });

      _mediaRecorder!.start();
      _isRecording = true;
      debugPrint('Recording started');

    } catch (e) {
      debugPrint('Error starting recording: $e');
      _isRecording = false;
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<Uint8List> stopRecording() async {
    if (!_isRecording || _mediaRecorder == null) {
      throw Exception('Not currently recording');
    }

    try {
      _mediaRecorder!.stop();
      _isRecording = false;
      
      // Wait for the recording to be processed
      return await _recordingCompleter!.future;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      throw Exception('Failed to stop recording: $e');
    }
  }

  Future<void> _processRecordedAudio() async {
    try {
      if (_recordedChunks.isEmpty) {
        throw Exception('No audio data recorded');
      }

      // Create blob from recorded chunks
      final blob = html.Blob(_recordedChunks, 'audio/webm');
      debugPrint('Created audio blob: ${blob.size} bytes');

      // Convert blob to Uint8List using proper type handling
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob);
      
      reader.onLoadEnd.listen((event) {
        try {
          // Properly handle the result type
          final result = reader.result;
          if (result != null) {
            // Convert to Uint8List safely
            final Uint8List audioData;
            if (result is ByteBuffer) {
              audioData = Uint8List.view(result);
            } else if (result is Uint8List) {
              audioData = result;
            } else {
              // Fallback: convert to string and then to bytes
              final bytes = (result as String).codeUnits;
              audioData = Uint8List.fromList(bytes);
            }
            
            debugPrint('Audio data ready: ${audioData.length} bytes');
            
            if (!_recordingCompleter!.isCompleted) {
              _recordingCompleter!.complete(audioData);
            }
          } else {
            throw Exception('No audio data received');
          }
        } catch (e) {
          debugPrint('Error processing audio data: $e');
          if (!_recordingCompleter!.isCompleted) {
            _recordingCompleter!.completeError('Failed to process audio data: $e');
          }
        }
      });

      reader.onError.listen((event) {
        debugPrint('Error reading audio blob: $event');
        if (!_recordingCompleter!.isCompleted) {
          _recordingCompleter!.completeError('Failed to read audio data');
        }
      });

    } catch (e) {
      debugPrint('Error processing recorded audio: $e');
      if (!_recordingCompleter!.isCompleted) {
        _recordingCompleter!.completeError('Failed to process audio: $e');
      }
    }
  }

  void dispose() {
    if (_isRecording) {
      _mediaRecorder?.stop();
    }
    
    _mediaStream?.getTracks().forEach((track) => track.stop());
    _mediaStream = null;
    _mediaRecorder = null;
    _isRecording = false;
    _recordedChunks.clear();
  }

  void initialize() {}
}
