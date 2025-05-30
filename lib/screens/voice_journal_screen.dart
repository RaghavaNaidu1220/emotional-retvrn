import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class VoiceJournalScreen extends StatefulWidget {
  const VoiceJournalScreen({Key? key}) : super(key: key);

  @override
  _VoiceJournalScreenState createState() => _VoiceJournalScreenState();
}

class _VoiceJournalScreenState extends State<VoiceJournalScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _openAIService = OpenAIService();
  final _supabase = Supabase.instance.client;

  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  String? _mPath;
  bool _isRecording = false;
  String _status = '';
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await _mRecorder.openRecorder();
    _mRecorderIsInited = true;
  }

  @override
  void dispose() {
    _mRecorder.closeRecorder();
    _mRecorderIsInited = false;
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!_mRecorderIsInited) return;

    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    _mPath = '/sdcard/$fileName'; // Ensure you have write permissions

    await _mRecorder.startRecorder(
      toFile: _mPath,
      codec: Codec.aacADTS,
    );

    setState(() {
      _isRecording = true;
      _status = 'Recording...';
    });
  }

  Future<void> _stopRecording() async {
    if (!_mRecorderIsInited) return;

    await _mRecorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _status = 'Processing audio...';
    });

    try {
      final transcription = await _openAIService.transcribeAudio(_mPath!);
      _textController.text = transcription;
      setState(() {
        _status = 'Transcription complete.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error transcribing audio: $e';
      });
    }
  }

  Future<void> _analyzeText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _status = 'Please add some text to analyze';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _status = 'Analyzing your thoughts...';
    });

    try {
      // Use OpenAI service for analysis
      final analysis = await _openAIService.analyzeEmotion(text);
      
      setState(() {
        _analysisResult = {
          'emotion': analysis['emotions'] != null ? 
              (analysis['emotions'] as Map<String, dynamic>).entries.first.key : 
              _extractEmotion(text),
          'mood': analysis['spiral_stage'] ?? _determineMood(text),
          'insights': analysis['insights'] ?? 'Your thoughts show depth and self-reflection.',
          'suggestions': analysis['suggestions'] != null ? 
              (analysis['suggestions'] as List).join('. ') : 
              'Consider exploring these feelings further through journaling.',
          'sentiment': _analyzeSentiment(text),
          'keywords': _extractKeywords(text),
        };
        _status = 'Analysis complete!';
      });
      
    } catch (e) {
      // Fallback to local analysis if OpenAI fails
      setState(() {
        _analysisResult = {
          'emotion': _extractEmotion(text),
          'mood': _determineMood(text),
          'insights': 'Your thoughts show depth and self-reflection. This entry reveals important aspects of your emotional state.',
          'suggestions': 'Consider exploring these feelings further through journaling or speaking with someone you trust.',
          'sentiment': _analyzeSentiment(text),
          'keywords': _extractKeywords(text),
        };
        _status = 'Analysis complete (offline mode)';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  String _extractEmotion(String text) {
    // Placeholder: Implement basic emotion detection logic here
    return 'Neutral';
  }

  String _determineMood(String text) {
    // Placeholder: Implement basic mood determination logic here
    return 'Calm';
  }

  String _analyzeSentiment(String text) {
    // Placeholder: Implement basic sentiment analysis logic here
    return 'Neutral';
  }

  List<String> _extractKeywords(String text) {
    // Placeholder: Implement basic keyword extraction logic here
    return ['thoughts', 'feelings'];
  }

  Future<void> _saveJournalEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _status = 'Journal entry is empty. Nothing to save.';
      });
      return;
    }

    setState(() {
      _status = 'Saving journal entry...';
    });

    try {
      final userId = _supabase.auth.currentUser!.id;
      final now = DateTime.now().toUtc();
      final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      final entryId = Uuid().v4();

      final entry = {
        'id': entryId,
        'user_id': userId,
        'created_at': now.toIso8601String(),
        'date': formattedDate,
        'text': text,
        'emotion': _analysisResult?['emotion'] ?? 'Unknown',
        'mood': _analysisResult?['mood'] ?? 'Unknown',
        'insights': _analysisResult?['insights'] ?? 'No insights.',
        'suggestions': _analysisResult?['suggestions'] ?? 'No suggestions.',
        'sentiment': _analysisResult?['sentiment'] ?? 'Neutral',
        'keywords': _analysisResult?['keywords'] ?? [],
      };

      await _supabase.from('journal_entries').insert(entry);

      setState(() {
        _status = 'Journal entry saved successfully!';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to save journal entry: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _isRecording ? null : _startRecording,
                  child: Text(_isRecording ? 'Recording...' : 'Start Recording'),
                ),
                ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : null,
                  child: const Text('Stop Recording'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_status),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts here...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isAnalyzing ? null : _analyzeText,
              child: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze Text'),
            ),
            if (_analysisResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Emotion: ${_analysisResult!['emotion'] ?? 'N/A'}'),
                    Text('Mood: ${_analysisResult!['mood'] ?? 'N/A'}'),
                    Text('Insights: ${_analysisResult!['insights'] ?? 'N/A'}'),
                    Text('Suggestions: ${_analysisResult!['suggestions'] ?? 'N/A'}'),
                    Text('Sentiment: ${_analysisResult!['sentiment'] ?? 'N/A'}'),
                    Text('Keywords: ${_analysisResult!['keywords']?.join(', ') ?? 'N/A'}'),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: _saveJournalEntry,
              child: const Text('Save Journal Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class OpenAIService {
  final String apiKey = const String.fromEnvironment('OPENAI_API_KEY');

  Future<String> transcribeAudio(String audioFilePath) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://api.openai.com/v1/audio/transcriptions'))
        ..headers.addAll({'Authorization': 'Bearer $apiKey'})
        ..fields['model'] = 'whisper-1'
        ..fields['language'] = 'en'
        ..files.add(await http.MultipartFile.fromPath('file', audioFilePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseBody)['text'];
      } else {
        throw 'Failed to transcribe audio: ${response.statusCode}, body: $responseBody';
      }
    } catch (e) {
      throw 'Error during audio transcription: $e';
    }
  }

  Future<Map<String, dynamic>> analyzeEmotion(String text) async {
    final prompt = '''
      Analyze the following text and extract the predominant emotion, mood (spiral stage), provide insights, and suggest actions.
      Text: "$text"
      Respond in JSON format with keys: "emotions" (a map of emotions and their scores), "spiral_stage", "insights", and "suggestions" (a list of suggestions).
      Example:
      {
        "emotions": {"joy": 0.8, "sadness": 0.1, "anger": 0.1},
        "spiral_stage": "Growth",
        "insights": "The text indicates a positive outlook and a focus on personal growth.",
        "suggestions": ["Continue practicing gratitude.", "Set new goals to maintain momentum."]
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant that analyzes text and provides emotional insights.'},
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        return jsonDecode(content);
      } else {
        throw 'Failed to analyze emotion: ${response.statusCode}, body: ${response.body}';
      }
    } catch (e) {
      throw 'Error during emotion analysis: $e';
    }
  }
}
