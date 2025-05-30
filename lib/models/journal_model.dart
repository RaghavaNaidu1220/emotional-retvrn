class JournalModel {
  final String? id;
  final String userId;
  final String? content;
  final String? audioUrl;
  final String? transcript;
  final DateTime createdAt;
  
  JournalModel({
    this.id,
    required this.userId,
    this.content,
    this.audioUrl,
    this.transcript,
    required this.createdAt,
  });
  
  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      audioUrl: json['audio_url'],
      transcript: json['transcript'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'content': content,
      'audio_url': audioUrl,
      'transcript': transcript,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
