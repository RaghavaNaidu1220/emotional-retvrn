import 'package:flutter/material.dart';
import '../models/journal_model.dart';
import '../models/emotion_analysis_model.dart';
import '../services/supabase_service.dart';
import '../services/openai_service.dart';

class JournalProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final OpenAIService _openAIService = OpenAIService();
  
  List<JournalModel> _journals = [];
  List<EmotionAnalysisModel> _analyses = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<JournalModel> get journals => _journals;
  List<EmotionAnalysisModel> get analyses => _analyses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
Future<void> loadJournals(String userId) async {
  if (_isLoading) return; // Prevent multiple simultaneous calls
  
  _setLoading(true);
  _clearError();
  
  try {
    _journals = await _supabaseService.getUserJournals(userId);
    await _loadAnalyses(userId);
    debugPrint('Loaded ${_journals.length} journals and ${_analyses.length} analyses');
  } catch (e) {
    debugPrint('Error loading journals: $e');
    _setError('Failed to load journals: ${e.toString()}');
    _journals = [];
    _analyses = [];
  } finally {
    _setLoading(false);
  }
}
  
  Future<void> _loadAnalyses(String userId) async {
    try {
      _analyses = await _supabaseService.getEmotionAnalyses(userId);
    } catch (e) {
      debugPrint('Error loading analyses: $e');
      _analyses = [];
    }
  }
  
  Future<bool> createJournal(JournalModel journal) async {
    _setLoading(true);
    _clearError();
    
    try {
      final createdJournal = await _supabaseService.createJournal(journal);
      _journals.insert(0, createdJournal);
      
      // Analyze the journal content with enhanced emotion analysis
      await _analyzeJournalWithDetails(createdJournal);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error creating journal: $e');
      _setError('Failed to save journal: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _analyzeJournalWithDetails(JournalModel journal) async {
    try {
      final content = journal.transcript ?? journal.content ?? '';
      if (content.isEmpty) return;
      
      debugPrint('Starting comprehensive emotion analysis...');
      
      // Enhanced emotion analysis with multiple insights
      final emotionAnalysis = await _openAIService.analyzeEmotion(content);
      final insights = await _openAIService.extractEmotionalInsights(content);
      final patterns = await _openAIService.identifyEmotionalPatterns(content);
      final summary = await _openAIService.generateEmotionalSummary(content);
      
      // Create comprehensive emotion analysis
      final enhancedAnalysis = EmotionAnalysisModel.fromOpenAI(
        journalId: journal.id!,
        analysis: {
          ...emotionAnalysis,
          'insights': insights,
          'patterns': patterns,
          'summary': summary,
          'analysis_timestamp': DateTime.now().toIso8601String(),
          'session_type': journal.content?.contains('AI responses:') == true ? 'ai_conversation' : 'regular_journal',
        },
      );
      
      await _supabaseService.saveEmotionAnalysis(enhancedAnalysis);
      _analyses.insert(0, enhancedAnalysis);
      notifyListeners();
      
      debugPrint('Comprehensive emotion analysis completed and saved');
      debugPrint('Analysis summary: $summary');
      debugPrint('Key insights: $insights');
      debugPrint('Emotional patterns: $patterns');
      
    } catch (e) {
      debugPrint('Error in comprehensive analysis: $e');
      // Don't throw error for analysis failure, just log it
    }
  }
  
  void clearData() {
    _journals.clear();
    _analyses.clear();
    _clearError();
    notifyListeners();
  }
  
  Future<String?> transcribeAudio(String audioPath) async {
    try {
      return await _openAIService.transcribeAudio(audioPath);
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      return null;
    }
  }
  
  // Get emotion analysis for a specific journal
  EmotionAnalysisModel? getAnalysisForJournal(String journalId) {
    try {
      return _analyses.firstWhere((analysis) => analysis.journalId == journalId);
    } catch (e) {
      return null;
    }
  }
  
  // Get recent emotional trends
  Map<String, dynamic> getEmotionalTrends() {
    if (_analyses.isEmpty) return {};
    
    try {
      final recentAnalyses = _analyses.take(10).toList();
      final emotions = <String, int>{};
      final sentiments = <String, int>{};
      
      for (final analysis in recentAnalyses) {
        // Count primary emotions
        if (analysis.primaryEmotion.isNotEmpty) {
          emotions[analysis.primaryEmotion] = (emotions[analysis.primaryEmotion] ?? 0) + 1;
        }
        
        // Count sentiment trends
        final sentiment = analysis.sentimentScore > 0.1 ? 'positive' : 
                         analysis.sentimentScore < -0.1 ? 'negative' : 'neutral';
        sentiments[sentiment] = (sentiments[sentiment] ?? 0) + 1;
      }
      
      return {
        'emotions': emotions,
        'sentiments': sentiments,
        'total_entries': recentAnalyses.length,
        'average_sentiment': recentAnalyses.map((a) => a.sentimentScore).reduce((a, b) => a + b) / recentAnalyses.length,
      };
    } catch (e) {
      debugPrint('Error calculating emotional trends: $e');
      return {};
    }
  }
  
void _setLoading(bool loading) {
  if (_isLoading != loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}

void _clearError() {
  if (_errorMessage != null) {
    _errorMessage = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
}
