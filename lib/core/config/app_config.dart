class AppConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://veclnhbatnkfzwscynag.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZlY2xuaGJhdG5rZnp3c2N5bmFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgwNTMxMDIsImV4cCI6MjA2MzYyOTEwMn0.39BsRkotRPFovaMVxaahnv_nIRxVj9HwwD3E-X3EtRA';
  
  // OpenAI Configuration
  static const String openAIApiKey = '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';
  
  // Hugging Face Configuration
  static const String huggingFaceApiKey = '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';
  
  // App Configuration
  static const String appName = 'Emotional Spiral';
  static const String appVersion = '1.0.0';
  
  // Spiral Dynamics Colors
  static const Map<String, Map<String, dynamic>> spiralColors = {
    'beige': {
      'name': 'Beige - Survival',
      'color': 0xFFF5F5DC,
      'description': 'Basic survival instincts and immediate needs'
    },
    'purple': {
      'name': 'Purple - Tribal',
      'color': 0xFF800080,
      'description': 'Tribal bonds, traditions, and rituals'
    },
    'red': {
      'name': 'Red - Power',
      'color': 0xFFFF0000,
      'description': 'Power, dominance, and self-assertion'
    },
    'blue': {
      'name': 'Blue - Order',
      'color': 0xFF0000FF,
      'description': 'Order, discipline, and moral purpose'
    },
    'orange': {
      'name': 'Orange - Achievement',
      'color': 0xFFFFA500,
      'description': 'Achievement, success, and material progress'
    },
    'green': {
      'name': 'Green - Community',
      'color': 0xFF008000,
      'description': 'Community, equality, and environmental awareness'
    },
    'yellow': {
      'name': 'Yellow - Integration',
      'color': 0xFFFFFF00,
      'description': 'Systems thinking and integration'
    },
    'turquoise': {
      'name': 'Turquoise - Holistic',
      'color': 0xFF40E0D0,
      'description': 'Holistic thinking and global consciousness'
    },
  };
}
