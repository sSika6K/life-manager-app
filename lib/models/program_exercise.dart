class ProgramExercise {
  final int? id;
  final int programId;
  final int exerciseId;
  final int orderIndex;
  final int sets;
  final int? reps;
  final int? durationSeconds;
  final int restSeconds;

  ProgramExercise({
    this.id,
    required this.programId,
    required this.exerciseId,
    required this.orderIndex,
    required this.sets,
    this.reps,
    this.durationSeconds,
    this.restSeconds = 90,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'program_id': programId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
      'sets': sets,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
    };
  }

  factory ProgramExercise.fromMap(Map<String, dynamic> map) {
    return ProgramExercise(
      id: map['id'],
      programId: map['program_id'],
      exerciseId: map['exercise_id'],
      orderIndex: map['order_index'],
      sets: map['sets'],
      reps: map['reps'],
      durationSeconds: map['duration_seconds'],
      restSeconds: map['rest_seconds'] ?? 90,
    );
  }
}
