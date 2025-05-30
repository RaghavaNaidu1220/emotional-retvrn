import 'package:flutter/material.dart';
import 'openai_service.dart';

class SimpleAnalyzerService {
  final OpenAIService _openAI = OpenAIService();
  
  Future<Map<String, dynamic>> analyzeText(String text) async {
    try {
      debugPrint('Analyzing text: $text');
      
      // Use the correct method from OpenAIService
      final analysisResult = await _openAI.analyzeEmotion(text);
      
      // Extract data from the analysis result
      final emotions = analysisResult['emotions'] as Map<String, dynamic>? ?? {};
      final spiralStage = analysisResult['spiral_stage'] as String? ?? 'blue';
      final suggestions = analysisResult['suggestions'] as List<dynamic>? ?? [];
      
      // Find the primary emotion (highest score)
      String primaryEmotion = 'neutral';
      double highestScore = 0;
      emotions.forEach((emotion, score) {
        if ((score as double) > highestScore) {
          highestScore = score;
          primaryEmotion = emotion;
        }
      });
      
      // Format suggestions
      String formattedSuggestions = suggestions.take(2).join('. ');
      if (formattedSuggestions.isEmpty) {
        formattedSuggestions = 'Continue reflecting on your emotions.';
      }
      
      return {
        'emotion': primaryEmotion,
        'mood': _getMoodFromEmotion(primaryEmotion),
        'insights': 'You appear to be at the $spiralStage level of consciousness development. ' +
                   'Your primary emotion is $primaryEmotion with ${(highestScore * 100).toStringAsFixed(0)}% intensity.',
        'suggestions': formattedSuggestions,
        'originalText': text,
        'spiralStage': spiralStage,
        'emotions': emotions,
      };
      
    } catch (e) {
      debugPrint('Analysis error: $e');
      return {
        'emotion': 'neutral',
        'mood': 'Neutral',
        'insights': 'Unable to analyze at this time.',
        'suggestions': 'Please try again later.',
        'originalText': text,
        'spiralStage': 'blue',
        'emotions': {'neutral': 0.5},
      };
    }
  }
  
  String _getMoodFromEmotion(String emotion) {
    final positiveEmotions = ['joy', 'happiness', 'gratitude', 'excitement', 'love'];
    final negativeEmotions = ['sadness', 'anger', 'fear', 'anxiety', 'frustration'];
    final neutralEmotions = ['surprise', 'curiosity', 'contemplation'];
    
    if (positiveEmotions.contains(emotion.toLowerCase())) {
      return 'Positive';
    } else if (negativeEmotions.contains(emotion.toLowerCase())) {
      return 'Challenging';
    } else {
      return 'Neutral';
    }
  }
}
