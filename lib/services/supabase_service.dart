import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/journal_model.dart';
import '../models/emotion_analysis_model.dart';
import '../models/user_model.dart';
import '../models/conversation_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Auth methods
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      debugPrint('Signing in with email: $email');
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      debugPrint('Sign in successful for user: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('Email sign-in error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      debugPrint('Signing up with email: $email');
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      debugPrint('Sign up successful for user: ${response.user?.email}');
      return response;
    } catch (e) {
      debugPrint('Email sign-up error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('Attempting Google sign-in...');
      
      // For web, use the proper OAuth flow
      if (kIsWeb) {
        try {
          final response = await _supabase.auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: kDebugMode 
              ? 'http://localhost:${Uri.base.port}/auth/callback'
              : '${Uri.base.origin}/auth/callback',
          );
          debugPrint('Google sign-in initiated for web: $response');
          return true;
        } catch (e) {
          debugPrint('Google OAuth error: $e');
          // If OAuth provider is not enabled, show helpful error
          if (e.toString().contains('provider is not enabled') || 
              e.toString().contains('validation_failed')) {
            throw Exception('Google sign-in is not enabled. Please enable Google OAuth provider in your Supabase project settings under Authentication > Providers.');
          }
          throw Exception('Google sign-in failed: ${e.toString()}');
        }
      } else {
        // For mobile
        final response = await _supabase.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.emotionalspiral://login-callback/',
        );
        debugPrint('Google sign-in initiated for mobile');
        return true;
      }
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      debugPrint('User signed out successfully');
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw Exception('Failed to sign out: $e');
    }
  }

  // User profile methods
  Future<void> createUserProfile(String userId, String name, String email) async {
    try {
      final user = UserModel(
        id: userId,
        email: email,
        name: name,
        displayName: name,
        spiralStage: 'beige',
        createdAt: DateTime.now(),
      );
      
      await _supabase.from('user_profiles').insert(user.toJson());
      debugPrint('User profile created successfully');
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<UserModel> getUserProfile(String userId) async {
    try {
      debugPrint('Loading user profile for: $userId');
      
      final response = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        debugPrint('User profile loaded from database');
        return UserModel.fromJson(response);
      } else {
        debugPrint('No user profile found, creating default profile');
        final defaultProfile = UserModel(
          id: userId,
          email: _supabase.auth.currentUser?.email ?? '',
          name: _supabase.auth.currentUser?.userMetadata?['full_name'] ?? 'User',
          displayName: _supabase.auth.currentUser?.userMetadata?['full_name'] ?? 'User',
          spiralStage: 'beige',
          createdAt: DateTime.now(),
        );
        
        await _supabase.from('user_profiles').insert(defaultProfile.toJson());
        return defaultProfile;
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      throw Exception('Failed to load user profile: $e');
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _supabase
          .from('user_profiles')
          .update(user.toJson())
          .eq('id', user.id);
      debugPrint('User profile updated successfully');
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Journal methods
  Future<List<JournalModel>> getUserJournals(String userId) async {
    try {
      debugPrint('Loading journals for user: $userId');
      
      final response = await _supabase
          .from('journals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('Loaded ${response.length} journals from database');
      return response.map((json) => JournalModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading journals: $e');
      return [];
    }
  }

  Future<JournalModel> createJournal(JournalModel journal) async {
    try {
      debugPrint('Creating journal for user: ${journal.userId}');
      
      final response = await _supabase
          .from('journals')
          .insert(journal.toJson())
          .select()
          .single();

      debugPrint('Journal created successfully in database');
      return JournalModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating journal: $e');
      throw Exception('Failed to create journal: $e');
    }
  }

  // Voice Journal - Fixed to use correct table
  Future<void> saveVoiceJournalEntry({
    required String userId,
    required String transcript,
    required Map<String, dynamic> analysisJson,
  }) async {
    try {
      debugPrint('Saving voice journal entry for user: $userId');
      
      // Save to voice_journal_entries table
      final response = await _supabase.from('voice_journal_entries').insert({
        'user_id': userId,
        'transcript': transcript,
        'analysis_json': analysisJson,
        'offline_mode': analysisJson['offline_mode'] ?? false,
        'api_error': analysisJson['api_error'],
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      debugPrint('Voice journal entry saved: $response');
    } catch (e) {
      debugPrint('Error saving voice journal entry: $e');
      throw Exception('Failed to save voice journal entry: $e');
    }
  }

  // AI Journal - Fixed to use correct table
  Future<void> saveAIJournalEntry({
    required String userId,
    required String inputText,
    required List<String> reflectiveQuestions,
    bool offlineMode = false,
    String? apiError,
  }) async {
    try {
      debugPrint('Saving AI journal entry for user: $userId');
      
      final response = await _supabase.from('ai_journal_entries').insert({
        'user_id': userId,
        'input_text': inputText,
        'reflective_questions': reflectiveQuestions,
        'offline_mode': offlineMode,
        'api_error': apiError,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      debugPrint('AI journal entry saved: $response');
    } catch (e) {
      debugPrint('Error saving AI journal entry: $e');
      throw Exception('Failed to save AI journal entry: $e');
    }
  }

  // Emotion analysis methods
  Future<List<EmotionAnalysisModel>> getEmotionAnalyses(String userId) async {
    try {
      debugPrint('Loading emotion analyses for user: $userId');
      
      final response = await _supabase
          .from('emotion_analyses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('Loaded ${response.length} emotion analyses from database');
      return response.map((json) => EmotionAnalysisModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading emotion analyses: $e');
      return [];
    }
  }

  Future<void> saveEmotionAnalysis(EmotionAnalysisModel analysis) async {
    try {
      await _supabase.from('emotion_analyses').insert(analysis.toJson());
      debugPrint('Emotion analysis saved successfully');
    } catch (e) {
      debugPrint('Error saving emotion analysis: $e');
      throw Exception('Failed to save emotion analysis: $e');
    }
  }

  // Progress tracking methods - FIXED
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      debugPrint('Loading user progress for: $userId');
      
      // Get journal count using correct syntax
      final journalResponse = await _supabase
          .from('journals')
          .select()
          .eq('user_id', userId);
    
      // Get voice journal count  
      final voiceJournalResponse = await _supabase
          .from('voice_journal_entries')
          .select()
          .eq('user_id', userId);

      // Get AI journal count
      final aiJournalResponse = await _supabase
          .from('ai_journal_entries')
          .select()
          .eq('user_id', userId);

      // Get recent emotion analyses - FIXED
      final emotionAnalysesResponse = await _supabase
          .from('emotion_analyses')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      return {
        'total_journals': journalResponse.length,
        'voice_journals': voiceJournalResponse.length,
        'ai_journals': aiJournalResponse.length,
        'emotion_analyses': emotionAnalysesResponse,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error loading user progress: $e');
      // Return default values if there's an error
      return {
        'total_journals': 0,
        'voice_journals': 0,
        'ai_journals': 0,
        'emotion_analyses': [],
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Conversation methods
  Future<List<ConversationModel>> getUserConversations(String userId) async {
    try {
      debugPrint('Loading conversations for user: $userId');
      
      final response = await _supabase
          .from('conversations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      debugPrint('Loaded ${response.length} conversations from database');
      return response.map((json) => ConversationModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading conversations: $e');
      return [];
    }
  }

  Future<ConversationModel> createConversation(ConversationModel conversation) async {
    try {
      final response = await _supabase
          .from('conversations')
          .insert(conversation.toJson())
          .select()
          .single();

      debugPrint('Conversation created successfully');
      return ConversationModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;
}
