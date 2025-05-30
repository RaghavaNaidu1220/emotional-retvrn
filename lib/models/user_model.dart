class UserModel {
  final String id;
  final String email;
  final String name;
  final String? displayName;
  final int? age;
  final String spiralStage;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.displayName,
    this.age,
    required this.spiralStage,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      displayName: json['display_name'],
      age: json['age'],
      spiralStage: json['spiral_stage'] ?? 'beige',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'display_name': displayName,
      'age': age,
      'spiral_stage': spiralStage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  UserModel copyWith({
    String? name,
    String? displayName,
    int? age,
    String? spiralStage,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      spiralStage: spiralStage ?? this.spiralStage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
