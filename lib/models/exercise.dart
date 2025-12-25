class Exercise {
  final int? id;
  final int? userId;
  final String name;
  final String category;
  final String description;
  final String? targetMuscle; // Nouveau
  final int? machineId; // Nouveau
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final int? restSeconds;

  Exercise({
    this.id,
    this.userId,
    required this.name,
    required this.category,
    required this.description,
    this.targetMuscle,
    this.machineId,
    this.sets,
    this.reps,
    this.durationSeconds,
    this.restSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'description': description,
      'target_muscle': targetMuscle,
      'machine_id': machineId,
      'sets': sets,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      targetMuscle: map['target_muscle'],
      machineId: map['machine_id'],
      sets: map['sets'],
      reps: map['reps'],
      durationSeconds: map['duration_seconds'],
      restSeconds: map['rest_seconds'],
    );
  }
}
