class PracticeModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String duration; // Changed to String to match usage
  final String difficulty; // Added difficulty field
  final String? videoUrl;
  final List<String> instructions;
  final List<String> benefits;
  final bool hasVideo; // Added hasVideo field
  final bool hasAudio; // Added hasAudio field
  final DateTime? createdAt;

  PracticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.difficulty,
    this.videoUrl,
    required this.instructions,
    required this.benefits,
    this.hasVideo = false,
    this.hasAudio = false,
    this.createdAt,
  });

  factory PracticeModel.fromJson(Map<String, dynamic> json) {
    return PracticeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      duration: json['duration'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      videoUrl: json['video_url'],
      instructions: List<String>.from(json['instructions'] ?? []),
      benefits: List<String>.from(json['benefits'] ?? []),
      hasVideo: json['has_video'] ?? false,
      hasAudio: json['has_audio'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'duration': duration,
      'difficulty': difficulty,
      'video_url': videoUrl,
      'instructions': instructions,
      'benefits': benefits,
      'has_video': hasVideo,
      'has_audio': hasAudio,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static List<PracticeModel> getSamplePractices() {
    return [
      PracticeModel(
        id: '1',
        title: 'Morning Mindfulness',
        description: 'Start your day with awareness and intention',
        category: 'Mindfulness',
        duration: '10 min',
        difficulty: 'Beginner',
        hasVideo: true,
        videoUrl: 'assets/videos/loom_message.mp4',
        instructions: [
          'Find a comfortable seated position',
          'Close your eyes and take three deep breaths',
          'Notice the sensations in your body',
          'Set an intention for your day',
        ],
        benefits: [
          'Increased awareness',
          'Better focus throughout the day',
          'Reduced stress and anxiety',
        ],
        createdAt: DateTime.now(),
      ),
      PracticeModel(
        id: '2',
        title: 'Box Breathing',
        description: 'Regulate your nervous system with structured breathing',
        category: 'Breathing',
        duration: '5 min',
        difficulty: 'Beginner',
        hasVideo: true,
        videoUrl: 'assets/videos/loom_message.mp4',
        instructions: [
          'Inhale for 4 counts',
          'Hold for 4 counts',
          'Exhale for 4 counts',
          'Hold empty for 4 counts',
          'Repeat the cycle',
        ],
        benefits: [
          'Calms the nervous system',
          'Improves focus',
          'Reduces anxiety',
        ],
        createdAt: DateTime.now(),
      ),
      PracticeModel(
        id: '3',
        title: 'Loving-Kindness Meditation',
        description: 'Cultivate compassion for yourself and others',
        category: 'Meditation',
        duration: '15 min',
        difficulty: 'Intermediate',
        hasVideo: true,
        videoUrl: 'assets/videos/loom_message.mp4',
        instructions: [
          'Begin with yourself: "May I be happy, may I be healthy"',
          'Extend to loved ones',
          'Include neutral people',
          'Embrace difficult relationships',
          'Expand to all beings',
        ],
        benefits: [
          'Increases empathy',
          'Reduces negative emotions',
          'Improves relationships',
        ],
        createdAt: DateTime.now(),
      ),
      PracticeModel(
        id: '4',
        title: 'Emotional Check-In',
        description: 'Tune into your emotional landscape',
        category: 'Emotional Regulation',
        duration: '8 min',
        difficulty: 'Beginner',
        hasVideo: true,
        videoUrl: 'assets/videos/loom_message.mp4',
        instructions: [
          'Pause and take a deep breath',
          'Scan your body for sensations',
          'Name the emotions you\'re feeling',
          'Accept them without judgment',
          'Choose your response mindfully',
        ],
        benefits: [
          'Better emotional awareness',
          'Improved self-regulation',
          'Reduced reactivity',
        ],
        createdAt: DateTime.now(),
      ),
      PracticeModel(
        id: '5',
        title: 'Spiral Dynamics Reflection',
        description: 'Explore your current level of consciousness',
        category: 'Spiral Dynamics',
        duration: '20 min',
        difficulty: 'Advanced',
        hasVideo: true,
        videoUrl: 'assets/videos/loom_message.mp4',
        instructions: [
          'Review the spiral dynamics stages',
          'Reflect on your current worldview',
          'Identify areas for growth',
          'Set intentions for evolution',
        ],
        benefits: [
          'Increased self-awareness',
          'Personal growth insights',
          'Better understanding of others',
        ],
        createdAt: DateTime.now(),
      ),
      PracticeModel(
        id: '6',
        title: 'Gratitude Journaling',
        description: 'Cultivate appreciation and positive emotions',
        category: 'Journaling',
        duration: '12 min',
        difficulty: 'Beginner',
        hasVideo: true,
        videoUrl: 'assets/videos/loom_message.mp4',
        instructions: [
          'Write down three things you\'re grateful for',
          'Describe why each one matters to you',
          'Feel the emotion of gratitude',
          'Reflect on how gratitude changes your perspective',
        ],
        benefits: [
          'Improved mood',
          'Better sleep quality',
          'Increased life satisfaction',
        ],
        createdAt: DateTime.now(),
      ),
    ];
  }
}
