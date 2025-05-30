import '../core/config/app_config.dart';

class SpiralDynamicsModel {
  final String stage;
  final String name;
  final int colorValue;
  final String description;
  final List<String> characteristics;
  final List<String> growthTips;
  
  SpiralDynamicsModel({
    required this.stage,
    required this.name,
    required this.colorValue,
    required this.description,
    required this.characteristics,
    required this.growthTips,
  });
  
  static List<SpiralDynamicsModel> getAllStages() {
    return [
      SpiralDynamicsModel(
        stage: 'beige',
        name: 'Beige - Survival',
        colorValue: 0xFFF5F5DC,
        description: 'Basic survival instincts, immediate needs',
        characteristics: [
          'Focus on basic survival needs',
          'Instinctual behavior',
          'Present-moment awareness',
          'Simple problem-solving'
        ],
        growthTips: [
          'Ensure basic needs are met',
          'Build safety and security',
          'Develop trust in environment',
          'Practice mindfulness'
        ],
      ),
      SpiralDynamicsModel(
        stage: 'purple',
        name: 'Purple - Tribal',
        colorValue: 0xFF800080,
        description: 'Tribal bonds, magical thinking, safety in group',
        characteristics: [
          'Strong tribal bonds',
          'Magical thinking',
          'Ritual and tradition',
          'Group safety'
        ],
        growthTips: [
          'Honor traditions while staying open',
          'Build community connections',
          'Practice gratitude rituals',
          'Explore spiritual practices'
        ],
      ),
      SpiralDynamicsModel(
        stage: 'red',
        name: 'Red - Power',
        colorValue: 0xFFFF0000,
        description: 'Power, dominance, immediate gratification',
        characteristics: [
          'Self-assertion',
          'Immediate gratification',
          'Power and dominance',
          'Breaking free from constraints'
        ],
        growthTips: [
          'Channel energy constructively',
          'Practice delayed gratification',
          'Develop self-discipline',
          'Learn from consequences'
        ],
      ),
      SpiralDynamicsModel(
        stage: 'blue',
        name: 'Blue - Order',
        colorValue: 0xFF0000FF,
        description: 'Rules, order, discipline, meaning and purpose',
        characteristics: [
          'Order and structure',
          'Moral codes',
          'Discipline',
          'Purpose and meaning'
        ],
        growthTips: [
          'Balance structure with flexibility',
          'Question rigid beliefs',
          'Practice compassion',
          'Explore different perspectives'
        ],
      ),
      SpiralDynamicsModel(
        stage: 'orange',
        name: 'Orange - Achievement',
        colorValue: 0xFFFFA500,
        description: 'Success, achievement, competition, progress',
        characteristics: [
          'Achievement orientation',
          'Competition',
          'Scientific thinking',
          'Progress and success'
        ],
        growthTips: [
          'Balance achievement with relationships',
          'Consider impact on others',
          'Practice collaboration',
          'Develop emotional intelligence'
        ],
      ),
      SpiralDynamicsModel(
        stage: 'green',
        name: 'Green - Community',
        colorValue: 0xFF008000,
        description: 'Harmony, equality, feelings, community',
        characteristics: [
          'Harmony and equality',
          'Emotional awareness',
          'Community focus',
          'Consensus building'
        ],
        growthTips: [
          'Balance consensus with decision-making',
          'Embrace healthy conflict',
          'Develop systems thinking',
          'Practice discernment'
        ],
      ),
      SpiralDynamicsModel(
        stage: 'yellow',
        name: 'Yellow - Integration',
        colorValue: 0xFFFFFF00,
        description: 'Flexibility, integration, natural systems',
        characteristics: [
          'Systems thinking',
          'Flexibility',
          'Integration of perspectives',
          'Natural hierarchies'
        ],
        growthTips: [
          'Practice integral thinking',
          'Embrace paradox',
          'Develop meta-cognitive skills',
          'Foster adaptive capacity'
        ],
      ),
      SpiralDynamicsModel(
        stage: 'turquoise',
        name: 'Turquoise - Holistic',
        colorValue: 0xFF40E0D0,
        description: 'Holistic thinking, global perspective, synthesis',
        characteristics: [
          'Holistic perspective',
          'Global consciousness',
          'Synthesis of all levels',
          'Spiritual integration'
        ],
        growthTips: [
          'Embody integral awareness',
          'Practice global thinking',
          'Integrate all perspectives',
          'Serve collective evolution'
        ],
      ),
    ];
  }
  
  static SpiralDynamicsModel? getStageByName(String stageName) {
    try {
      return getAllStages().firstWhere((stage) => stage.stage == stageName);
    } catch (e) {
      return null;
    }
  }
}
