class ConversationMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ConversationMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      text: json['text'] ?? '',
      isUser: json['is_user'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ConversationModel {
  final String id;
  final String userId;
  final List<ConversationMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? emotionAnalysis;
  
  ConversationModel({
    required this.id,
    required this.userId,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.emotionAnalysis,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'emotion_analysis': emotionAnalysis,
    };
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => ConversationMessage.fromJson(m))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      emotionAnalysis: json['emotion_analysis'],
    );
  }
}
