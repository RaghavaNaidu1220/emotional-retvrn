import 'openai_service.dart';
import 'package:flutter/foundation.dart';

class AIChatService {
  final OpenAIService _openAIService = OpenAIService();

  Future<String> getReflectiveQuestion(String? recentEntry) async {
    try {
      return await _openAIService.generateReflectiveQuestion(
        recentEntry ?? '', // Required positional argument
        conversationContext: '' // String instead of List
      );
    } catch (e) {
      debugPrint('Error getting reflective question: $e');
      return 'What emotions are most present for you right now?';
    }
  }

  Future<String> getFollowUpQuestion(String journalText) async {
    try {
      return await _openAIService.getFollowUpQuestion(journalText);
    } catch (e) {
      debugPrint('Error getting follow-up question: $e');
      return 'How might you explore these thoughts more deeply?';
    }
  }

  Future<String> getEmotionalInsight(List<String> recentEntries) async {
    try {
      return await _openAIService.getEmotionalInsight(recentEntries);
    } catch (e) {
      debugPrint('Error getting emotional insight: $e');
      return 'Your journal entries show a developing emotional awareness.';
    }
  }
}
