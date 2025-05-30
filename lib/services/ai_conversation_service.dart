import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/conversation_model.dart';

class AIConversationService {
  // Track conversation context for better responses
  String _conversationContext = '';
  List<String> _detectedEmotions = [];
  int _questionCount = 0;
  
  Future<String> getResponse(String userMessage, List<ConversationMessage> conversation) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Update conversation context
    _updateConversationContext(userMessage, conversation);
    
    // Convert message to lowercase for easier matching
    final messageLower = userMessage.toLowerCase();
    
    // Detect emotions in the message
    _detectEmotions(messageLower);
    
    // Generate contextual response based on conversation flow
    return _generateContextualResponse(userMessage, messageLower, conversation);
  }
  
  void _updateConversationContext(String userMessage, List<ConversationMessage> conversation) {
    _conversationContext += ' $userMessage';
    _questionCount = conversation.where((m) => !m.isUser).length;
  }
  
  void _detectEmotions(String messageLower) {
    _detectedEmotions.clear();
    
    if (messageLower.contains('happy') || messageLower.contains('joy') || messageLower.contains('glad') || messageLower.contains('excited')) {
      _detectedEmotions.add('joy');
    }
    if (messageLower.contains('sad') || messageLower.contains('down') || messageLower.contains('depressed') || messageLower.contains('upset')) {
      _detectedEmotions.add('sadness');
    }
    if (messageLower.contains('angry') || messageLower.contains('mad') || messageLower.contains('frustrated') || messageLower.contains('annoyed')) {
      _detectedEmotions.add('anger');
    }
    if (messageLower.contains('anxious') || messageLower.contains('worried') || messageLower.contains('stress') || messageLower.contains('nervous')) {
      _detectedEmotions.add('anxiety');
    }
    if (messageLower.contains('tired') || messageLower.contains('exhausted') || messageLower.contains('drained')) {
      _detectedEmotions.add('fatigue');
    }
    if (messageLower.contains('confused') || messageLower.contains('lost') || messageLower.contains('uncertain')) {
      _detectedEmotions.add('confusion');
    }
    if (messageLower.contains('grateful') || messageLower.contains('thankful') || messageLower.contains('blessed')) {
      _detectedEmotions.add('gratitude');
    }
    if (messageLower.contains('love') || messageLower.contains('caring') || messageLower.contains('affection')) {
      _detectedEmotions.add('love');
    }
  }
  
  String _generateContextualResponse(String userMessage, String messageLower, List<ConversationMessage> conversation) {
    // Handle specific conversation flows
    if (_questionCount == 1) {
      return _getOpeningResponse(messageLower);
    } else if (_questionCount == 2) {
      return _getDeepenerResponse(messageLower);
    } else if (_questionCount == 3) {
      return _getExplorationResponse(messageLower);
    } else if (_questionCount == 4) {
      return _getInsightResponse(messageLower);
    } else if (_questionCount >= 5) {
      return _getClosingResponse(messageLower);
    }
    
    // Fallback responses
    return _getEmotionBasedResponse(messageLower);
  }
  
  String _getOpeningResponse(String messageLower) {
    if (_detectedEmotions.contains('joy')) {
      return "That's wonderful to hear! What specifically happened today that brought you this happiness? I'd love to understand what's lighting you up.";
    } else if (_detectedEmotions.contains('sadness')) {
      return "I can hear that you're going through a difficult time. Would you feel comfortable sharing what's weighing on your heart right now?";
    } else if (_detectedEmotions.contains('anger')) {
      return "It sounds like something really got to you today. What happened that triggered these feelings? Sometimes talking through it can help us understand what's really going on.";
    } else if (_detectedEmotions.contains('anxiety')) {
      return "I notice you're feeling anxious. What thoughts or situations are creating this worry for you? Let's explore what's behind these feelings.";
    } else if (_detectedEmotions.contains('fatigue')) {
      return "It sounds like you're feeling really drained. What's been demanding so much of your energy lately? Let's talk about what might be contributing to this exhaustion.";
    } else {
      return "Thank you for sharing that with me. Can you tell me more about what's been on your mind today? What emotions are you experiencing right now?";
    }
  }
  
  String _getDeepenerResponse(String messageLower) {
    if (_detectedEmotions.contains('joy')) {
      return "I love hearing about what brings you joy! How does this happiness feel in your body? And what does this positive experience tell you about what you value most?";
    } else if (_detectedEmotions.contains('sadness')) {
      return "Thank you for trusting me with these difficult feelings. When did you first notice this sadness? Have you experienced similar feelings before, and if so, what helped you through it?";
    } else if (_detectedEmotions.contains('anger')) {
      return "Your anger is telling us something important. Beneath this anger, what other emotions might be hiding? Sometimes anger protects us from feeling hurt or fear - does that resonate with you?";
    } else if (_detectedEmotions.contains('anxiety')) {
      return "Anxiety often tries to protect us by preparing for potential threats. What specifically is your mind trying to protect you from? What's the worst-case scenario you're imagining?";
    } else {
      return "I'm hearing several layers in what you're sharing. What feels most important for you to explore right now? What emotion feels strongest in this moment?";
    }
  }
  
  String _getExplorationResponse(String messageLower) {
    if (_conversationContext.contains('work') || _conversationContext.contains('job')) {
      return "It sounds like work is playing a significant role in how you're feeling. How do you think your work situation is affecting other areas of your life? What would need to change for you to feel more balanced?";
    } else if (_conversationContext.contains('relationship') || _conversationContext.contains('family') || _conversationContext.contains('friend')) {
      return "Relationships can deeply impact our emotional well-being. What patterns do you notice in your relationships? How do you typically handle conflict or difficult conversations?";
    } else if (_conversationContext.contains('future') || _conversationContext.contains('goal') || _conversationContext.contains('plan')) {
      return "I hear you thinking about the future. What hopes and fears do you have about what's ahead? How do these future thoughts affect how you feel in the present moment?";
    } else {
      return "You're showing real insight into your emotional experience. What patterns do you notice in how you respond to challenging situations? What coping strategies have served you well in the past?";
    }
  }
  
  String _getInsightResponse(String messageLower) {
    return "You've shared so much valuable insight about your emotional experience. Looking at everything we've discussed, what stands out to you the most? What would you like to remember from our conversation today?";
  }
  
  String _getClosingResponse(String messageLower) {
    if (messageLower.contains('thank') || messageLower.contains('help')) {
      return "It's been an honor to explore these feelings with you. What's one small step you could take today to honor what you've discovered about yourself? How will you carry this awareness forward?";
    } else {
      return "Our conversation has revealed so much about your emotional wisdom. What feels different for you now compared to when we started talking? What would you like to focus on moving forward?";
    }
  }
  
  String _getEmotionBasedResponse(String messageLower) {
    // Fallback emotion-based responses
    if (_detectedEmotions.contains('joy')) {
      return "Your joy is contagious! What other areas of your life could benefit from this positive energy you're feeling?";
    } else if (_detectedEmotions.contains('sadness')) {
      return "Sadness often carries important messages about what matters to us. What is your sadness trying to tell you?";
    } else if (_detectedEmotions.contains('anger')) {
      return "Your anger is valid and important. What boundaries might need to be set or honored based on what you're feeling?";
    } else if (_detectedEmotions.contains('anxiety')) {
      return "Anxiety can be overwhelming. What would help you feel more grounded and present right now?";
    } else {
      return "I appreciate you continuing to share with me. What feels most alive or important for you to explore right now?";
    }
  }
  
  Future<Map<String, dynamic>> analyzeEmotions(String userText) async {
    // Enhanced emotion analysis with better detection
    await Future.delayed(const Duration(milliseconds: 800));
    
    final textLower = userText.toLowerCase();
    
    // More sophisticated emotion detection
    Map<String, double> emotions = {
      'joy': _calculateEmotionScore(textLower, ['happy', 'joy', 'glad', 'excited', 'thrilled', 'delighted', 'cheerful', 'elated']),
      'sadness': _calculateEmotionScore(textLower, ['sad', 'down', 'depressed', 'upset', 'melancholy', 'gloomy', 'heartbroken', 'dejected']),
      'anger': _calculateEmotionScore(textLower, ['angry', 'mad', 'frustrated', 'annoyed', 'furious', 'irritated', 'outraged', 'livid']),
      'fear': _calculateEmotionScore(textLower, ['anxious', 'worried', 'stressed', 'nervous', 'scared', 'afraid', 'terrified', 'panicked']),
      'surprise': _calculateEmotionScore(textLower, ['shocked', 'amazed', 'unexpected', 'stunned', 'astonished', 'bewildered']),
      'disgust': _calculateEmotionScore(textLower, ['disgusted', 'revolting', 'gross', 'repulsed', 'sickened', 'appalled']),
      'trust': _calculateEmotionScore(textLower, ['trust', 'believe', 'faith', 'confident', 'secure', 'reliable']),
      'anticipation': _calculateEmotionScore(textLower, ['hope', 'looking forward', 'excited', 'eager', 'optimistic', 'expectant']),
    };
    
    // Normalize scores
    final maxScore = emotions.values.reduce((a, b) => a > b ? a : b);
    if (maxScore > 0) {
      emotions = emotions.map((key, value) => MapEntry(key, value / maxScore));
    }
    
    // Generate insights based on emotions
    List<String> insights = _generateEmotionalInsights(emotions);
    String dominantEmotion = _getDominantEmotion(emotions);
    
    return {
      'emotions': emotions,
      'dominant_emotion': dominantEmotion,
      'insights': insights,
      'timestamp': DateTime.now().toIso8601String(),
      'conversation_context': _conversationContext,
      'detected_themes': _detectedEmotions,
    };
  }
  
  double _calculateEmotionScore(String text, List<String> keywords) {
    double score = 0.0;
    for (String keyword in keywords) {
      if (text.contains(keyword)) {
        score += 1.0;
        // Bonus for exact word matches
        if (text.split(' ').contains(keyword)) {
          score += 0.5;
        }
      }
    }
    return score;
  }
  
  String _getDominantEmotion(Map<String, double> emotions) {
    String dominantEmotion = 'neutral';
    double maxScore = 0.2;
    
    emotions.forEach((emotion, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantEmotion = emotion;
      }
    });
    
    return dominantEmotion;
  }
  
  List<String> _generateEmotionalInsights(Map<String, double> emotions) {
    List<String> insights = [];
    
    emotions.forEach((emotion, score) {
      if (score > 0.5) {
        switch (emotion) {
          case 'joy':
            insights.add("Your positive emotions are creating space for creativity and connection.");
            insights.add("This joyful energy can be a resource for facing future challenges.");
            break;
          case 'sadness':
            insights.add("Your sadness shows your capacity for deep feeling and connection.");
            insights.add("This emotion often signals that something important to you needs attention.");
            break;
          case 'anger':
            insights.add("Your anger may be highlighting important boundaries or values.");
            insights.add("This energy can be channeled into positive change and advocacy.");
            break;
          case 'fear':
            insights.add("Your anxiety shows your mind's attempt to prepare and protect you.");
            insights.add("Acknowledging these fears can help you develop coping strategies.");
            break;
          case 'surprise':
            insights.add("Surprise opens you to new perspectives and learning opportunities.");
            insights.add("This emotion suggests you're encountering something meaningful.");
            break;
          case 'trust':
            insights.add("Your sense of trust creates a foundation for deeper relationships.");
            insights.add("This feeling can help you take positive risks for growth.");
            break;
          case 'anticipation':
            insights.add("Your forward-looking energy can fuel motivation and planning.");
            insights.add("This emotion suggests you're ready for positive change.");
            break;
        }
      }
    });
    
    if (insights.isEmpty) {
      insights.add("Your emotional expression shows thoughtful self-reflection.");
      insights.add("This awareness is the first step toward emotional growth.");
    }
    
    return insights;
  }
  
  // Reset conversation context for new sessions
  void resetConversation() {
    _conversationContext = '';
    _detectedEmotions.clear();
    _questionCount = 0;
  }
}
