import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/config/app_config.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _defaultModel = 'gpt-3.5-turbo';
  
  // Add flag to track API availability
  static bool _apiAvailable = true;
  static String _lastError = '';
  
  // Use direct API key from config
  String get _apiKey => AppConfig.openAIApiKey;
  
  // Add initialize method (for compatibility)
  void initialize() {
    debugPrint('OpenAI service initialized with direct API key');
    debugPrint('API key available: ${_apiKey.isNotEmpty}');
  }
  
  // Check if API is available
  bool get isApiAvailable => _apiAvailable && _apiKey.isNotEmpty;
  String get lastError => _lastError;
  
  Future<List<String>> generateReflectiveQuestionsFromInput(String userInput) async {
    // If API is not available, return default questions immediately
    if (!isApiAvailable) {
      debugPrint('OpenAI API not available, using default questions');
      return _getDefaultReflectiveQuestions(userInput);
    }
    
    try {
      debugPrint('Generating reflective questions for input: $userInput');
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _defaultModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a compassionate self-reflection assistant. Based on the user\'s input, you will generate thoughtful and emotionally intelligent questions that help the user explore their thoughts and feelings more deeply. Return 3-5 questions, each on a new line.'
            },
            {
              'role': 'user',
              'content': userInput
            }
          ],
          'temperature': 0.8,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        debugPrint('OpenAI reflective questions generated successfully');
        
        // Reset API availability flag on success
        _apiAvailable = true;
        _lastError = '';
        
        final questions = content.split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.trim().replaceFirst(RegExp(r'^\d+\.\s*'), ''))
            .toList();
        
        return questions;
      } else if (response.statusCode == 429) {
        // Quota exceeded - disable API temporarily
        _apiAvailable = false;
        _lastError = 'OpenAI quota exceeded. Using offline analysis.';
        debugPrint('OpenAI quota exceeded, switching to offline mode');
        return _getDefaultReflectiveQuestions(userInput);
      } else {
        debugPrint('OpenAI API error: ${response.statusCode} - ${response.body}');
        return _getDefaultReflectiveQuestions(userInput);
      }
    } catch (e) {
      debugPrint('Error generating reflective questions: $e');
      return _getDefaultReflectiveQuestions(userInput);
    }
  }

  Future<Map<String, dynamic>> analyzeEmotionalContent(String transcript) async {
    // If API is not available, return default analysis immediately
    if (!isApiAvailable) {
      debugPrint('OpenAI API not available, using default analysis');
      return _getDefaultEmotionalAnalysis(transcript);
    }
    
    try {
      debugPrint('Analyzing emotional content: $transcript');
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _defaultModel,
          'messages': [
            {
              'role': 'system',
              'content': '''You are an expert emotional intelligence analyst. Analyze the given text and provide a comprehensive emotional analysis in JSON format with the following structure:
{
  "primary_emotion": "main emotion detected",
  "intensity": "low/medium/high",
  "themes": ["theme1", "theme2", "theme3"],
  "insights": "brief insight about emotional patterns",
  "suggestions": ["suggestion1", "suggestion2", "suggestion3"]
}

Focus on being supportive, accurate, and helpful in your analysis.'''
            },
            {
              'role': 'user',
              'content': transcript
            }
          ],
          'temperature': 0.7,
        }),
      );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      debugPrint('OpenAI emotional analysis completed successfully');
      
      // Reset API availability flag on success
      _apiAvailable = true;
      _lastError = '';
      
      try {
        return jsonDecode(content);
      } catch (e) {
        debugPrint('Error parsing JSON response: $e');
        return _getDefaultEmotionalAnalysis(transcript);
      }
    } else if (response.statusCode == 429) {
      // Quota exceeded - disable API temporarily
      _apiAvailable = false;
      _lastError = 'OpenAI quota exceeded. Using offline analysis.';
      debugPrint('OpenAI quota exceeded, switching to offline mode');
      return _getDefaultEmotionalAnalysis(transcript);
    } else {
      debugPrint('OpenAI API error: ${response.statusCode} - ${response.body}');
      return _getDefaultEmotionalAnalysis(transcript);
    }
    } catch (e) {
      debugPrint('Error analyzing emotional content: $e');
      return _getDefaultEmotionalAnalysis(transcript);
    }
  }

  List<String> _getDefaultReflectiveQuestions(String userInput) {
    final lowerInput = userInput.toLowerCase();
    
    if (lowerInput.contains('stress') || lowerInput.contains('anxious')) {
      return [
        "What specific aspects of this situation feel most overwhelming to you?",
        "When do you feel most calm and centered, and what creates that feeling?",
        "What would you tell a close friend who was experiencing this same stress?",
        "How might you break this challenge into smaller, more manageable pieces?"
      ];
    } else if (lowerInput.contains('career') || lowerInput.contains('work')) {
      return [
        "What aspects of your career bring you the most fulfillment?",
        "How do your current career choices align with your core values?",
        "What fears or expectations might be influencing your career decisions?",
        "If you could design your ideal work life, what would it look like?"
      ];
    } else if (lowerInput.contains('relationship') || lowerInput.contains('family')) {
      return [
        "What patterns do you notice in your relationships?",
        "How do you typically express your needs and boundaries?",
        "What would healthy communication look like in this situation?",
        "How might you show more compassion to yourself and others involved?"
      ];
    } else if (lowerInput.contains('happy') || lowerInput.contains('joy') || lowerInput.contains('proud')) {
      return [
        "What specifically about this accomplishment brings you the most joy?",
        "How can you celebrate this achievement in a meaningful way?",
        "What strengths did you demonstrate that led to this success?",
        "How might you build on this positive experience in the future?"
      ];
    } else {
      return [
        "What emotions are you experiencing most strongly right now?",
        "How might this experience be helping you grow as a person?",
        "What would it look like to approach this situation with more self-compassion?",
        "What small step could you take today to support yourself through this?"
      ];
    }
  }

  Map<String, dynamic> _getDefaultEmotionalAnalysis(String transcript) {
    final lowerText = transcript.toLowerCase();
    
    String primaryEmotion = 'neutral';
    String intensity = 'medium';
    List<String> themes = [];
    String insights = '';
    List<String> suggestions = [];
    
    // Detect primary emotion
    if (lowerText.contains('happy') || lowerText.contains('joy') || lowerText.contains('excited')) {
      primaryEmotion = 'joy';
      intensity = 'high';
      themes = ['positivity', 'gratitude', 'celebration'];
      insights = 'You\'re experiencing positive emotions that can enhance your overall well-being.';
      suggestions = ['Savor this positive moment', 'Share your joy with others', 'Reflect on what created this happiness'];
    } else if (lowerText.contains('sad') || lowerText.contains('down') || lowerText.contains('depressed')) {
      primaryEmotion = 'sadness';
      intensity = lowerText.contains('very') || lowerText.contains('extremely') ? 'high' : 'medium';
      themes = ['loss', 'disappointment', 'reflection'];
      insights = 'Sadness is a natural emotion that often signals the need for self-care and support.';
      suggestions = ['Practice self-compassion', 'Reach out to supportive friends', 'Consider what you might need right now'];
    } else if (lowerText.contains('stress') || lowerText.contains('anxious') || lowerText.contains('worried')) {
      primaryEmotion = 'anxiety';
      intensity = 'medium';
      themes = ['uncertainty', 'pressure', 'future concerns'];
      insights = 'Your anxiety may be highlighting areas where you need more support or clarity.';
      suggestions = ['Practice deep breathing', 'Break challenges into smaller steps', 'Focus on what you can control'];
    } else if (lowerText.contains('angry') || lowerText.contains('frustrated') || lowerText.contains('mad')) {
      primaryEmotion = 'anger';
      intensity = 'medium';
      themes = ['boundaries', 'unmet needs', 'justice'];
      insights = 'Anger often signals that something important to you needs attention.';
      suggestions = ['Identify what boundary was crossed', 'Express your needs clearly', 'Take time to cool down before responding'];
    } else if (lowerText.contains('proud') || lowerText.contains('accomplish') || lowerText.contains('complete')) {
      primaryEmotion = 'pride';
      intensity = 'high';
      themes = ['achievement', 'success', 'self-worth'];
      insights = 'Your sense of pride reflects your investment in this accomplishment and recognition of your capabilities.';
      suggestions = ['Celebrate your achievement', 'Acknowledge your hard work', 'Share your success with supportive people'];
    }
    
    return {
      'primary_emotion': primaryEmotion,
      'intensity': intensity,
      'themes': themes,
      'insights': insights,
      'suggestions': suggestions,
    };
  }

  // Keep existing methods for backward compatibility
  Future<Map<String, dynamic>> analyzeEmotion(String text) async {
    return await analyzeEmotionalContent(text);
  }

  Future<String> generateReflectiveQuestion(String text, {required String conversationContext}) async {
    final questions = await generateReflectiveQuestionsFromInput(text);
    return questions.isNotEmpty ? questions.first : 'What are you feeling right now?';
  }

  Future<String> getFollowUpQuestion(String journalText) async {
    final questions = await generateReflectiveQuestionsFromInput(journalText);
    return questions.length > 1 ? questions[1] : 'How might you explore these thoughts more deeply?';
  }

  Future<String> getEmotionalInsight(List<String> journalEntries) async {
    final combinedText = journalEntries.join(' ');
    final analysis = await analyzeEmotionalContent(combinedText);
    return analysis['insights'] ?? 'Your journal entries show emotional awareness and growth.';
  }

  Future<List<String>> generateMeaningfulQuestions(String text) async {
    return await generateReflectiveQuestionsFromInput(text);
  }

  Future<String> extractEmotionalInsights(String text) async {
    final analysis = await analyzeEmotionalContent(text);
    return analysis['insights'] ?? 'Your thoughts show depth and self-reflection.';
  }

  Future<List<String>> identifyEmotionalPatterns(String text) async {
    final analysis = await analyzeEmotionalContent(text);
    return List<String>.from(analysis['themes'] ?? ['emotional awareness']);
  }

  Future<String> generateEmotionalSummary(String text) async {
    final analysis = await analyzeEmotionalContent(text);
    return 'Primary emotion: ${analysis['primary_emotion']}, Intensity: ${analysis['intensity']}';
  }

  Future<String> transcribeAudio(String audioPath) async {
    throw Exception('Audio transcription not supported on web. Use speech-to-text instead.');
  }

  Future generateResponse(String prompt) async {}
}
