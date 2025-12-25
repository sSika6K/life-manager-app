class SetHistory {
  final int? id;
  final int userId;
  final int exerciseId;
  final int programId;
  final DateTime date;
  final int setNumber;
  final double? weight; // Poids soulevé (null si poids du corps)
  final int? reps;
  final int? durationSeconds;

  SetHistory({
    this.id,
    required this.userId,
    required this.exerciseId,
    required this.programId,
    required this.date,
    required this.setNumber,
    this.weight,
    this.reps,
    this.durationSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'exercise_id': exerciseId,
      'program_id': programId,
      'date': date.toIso8601String(),
      'set_number': setNumber,
      'weight': weight,
      'reps': reps,
      'duration_seconds': durationSeconds,
    };
  }

  factory SetHistory.fromMap(Map<String, dynamic> map) {
    return SetHistory(
      id: map['id'],
      userId: map['user_id'],
      exerciseId: map['exercise_id'],
      programId: map['program_id'],
      date: DateTime.parse(map['date']),
      setNumber: map['set_number'],
      weight: map['weight'] != null ? (map['weight'] as num).toDouble() : null,
      reps: map['reps'],
      durationSeconds: map['duration_seconds'],
    );
  }
}
