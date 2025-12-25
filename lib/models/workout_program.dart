class WorkoutProgram {
  final int? id;
  final int userId;
  final String name;
  final List<String> targetMuscles; // Liste des muscles ciblés
  final DateTime createdAt;

  WorkoutProgram({
    this.id,
    required this.userId,
    required this.name,
    required this.targetMuscles,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'target_muscles': targetMuscles.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkoutProgram.fromMap(Map<String, dynamic> map) {
    return WorkoutProgram(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      targetMuscles: (map['target_muscles'] as String).split(','),
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
