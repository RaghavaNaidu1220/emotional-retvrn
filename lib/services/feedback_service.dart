import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';

class FeedbackService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> submitFeedback({
    required String type,
    required String title,
    required String description,
    String? userEmail,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _client.auth.currentUser;
      
      await _client.from('feedback').insert({
        'user_id': user?.id,
        'user_email': userEmail ?? user?.email,
        'type': type,
        'title': title,
        'description': description,
        'metadata': metadata,
        'status': 'open',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Feedback submitted successfully');
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
      rethrow;
    }
  }

  Future<void> submitBugReport({
    required String title,
    required String description,
    required String stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
    Map<String, dynamic>? deviceInfo,
  }) async {
    await submitFeedback(
      type: 'bug',
      title: title,
      description: description,
      metadata: {
        'steps_to_reproduce': stepsToReproduce,
        'expected_behavior': expectedBehavior,
        'actual_behavior': actualBehavior,
        'device_info': deviceInfo,
      },
    );
  }

  Future<void> submitFeatureRequest({
    required String title,
    required String description,
    String? useCase,
    String? priority,
  }) async {
    await submitFeedback(
      type: 'feature_request',
      title: title,
      description: description,
      metadata: {
        'use_case': useCase,
        'priority': priority,
      },
    );
  }
}
