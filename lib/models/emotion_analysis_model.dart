class EmotionAnalysisModel {
  final String? id;
  final String journalId;
  final Map<String, double> emotions;
  final String spiralColor;
  final List<String> suggestions;
  final double confidenceScore;
  final DateTime createdAt;
  final double sentimentScore;
  final String? insights;
  final List<String>? patterns;
  final String? summary;
  
  EmotionAnalysisModel({
    this.id,
    required this.journalId,
    required this.emotions,
    required this.spiralColor,
    required this.suggestions,
    required this.confidenceScore,
    required this.createdAt,
    this.sentimentScore = 0.0,
    this.insights,
    this.patterns,
    this.summary,
  });
  
  factory EmotionAnalysisModel.fromJson(Map<String, dynamic> json) {
    return EmotionAnalysisModel(
      id: json['id'],
      journalId: json['journal_id'],
      emotions: Map<String, double>.from(json['emotions']),
      spiralColor: json['spiral_color'],
      suggestions: List<String>.from(json['suggestions']),
      confidenceScore: json['confidence_score'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      sentimentScore: (json['sentiment_score'] ?? 0.0).toDouble(),
      insights: json['insights'],
      patterns: json['patterns'] != null ? List<String>.from(json['patterns']) : null,
      summary: json['summary'],
    );
  }
  
  factory EmotionAnalysisModel.fromOpenAI({
    required String journalId,
    required Map<String, dynamic> analysis,
  }) {
    // Calculate sentiment score from emotions
    final emotions = Map<String, double>.from(analysis['emotions']);
    double sentimentScore = 0.0;
    
    // Calculate sentiment based on emotion types
    emotions.forEach((emotion, confidence) {
      switch (emotion.toLowerCase()) {
        case 'joy':
        case 'happiness':
        case 'gratitude':
        case 'love':
        case 'excitement':
          sentimentScore += confidence * 1.0;
          break;
        case 'sadness':
        case 'anger':
        case 'fear':
        case 'anxiety':
        case 'frustration':
          sentimentScore -= confidence * 1.0;
          break;
        default:
          // Neutral emotions don't affect sentiment
          break;
      }
    });
    
    return EmotionAnalysisModel(
      journalId: journalId,
      emotions: emotions,
      spiralColor: analysis['spiral_stage'],
      suggestions: List<String>.from(analysis['suggestions']),
      confidenceScore: analysis['confidence'].toDouble(),
      createdAt: DateTime.now(),
      sentimentScore: sentimentScore.clamp(-1.0, 1.0),
      insights: analysis['insights'],
      patterns: analysis['patterns'] != null ? List<String>.from(analysis['patterns']) : null,
      summary: analysis['summary'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'journal_id': journalId,
      'emotions': emotions,
      'spiral_color': spiralColor,
      'suggestions': suggestions,
      'confidence_score': confidenceScore,
      'created_at': createdAt.toIso8601String(),
      'sentiment_score': sentimentScore,
      'insights': insights,
      'patterns': patterns,
      'summary': summary,
    };
  }
  
  String get primaryEmotion {
    if (emotions.isEmpty) return 'Unknown';
    return emotions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
