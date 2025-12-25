class ActiveSession {
  final int? id;
  final int userId;
  final int programId;
  final DateTime startTime;
  final Map<int, int> remainingSets; // exerciseId -> séries restantes
  final int? selectedExerciseId;
  final bool isResting;
  final int restTimeRemaining;

  ActiveSession({
    this.id,
    required this.userId,
    required this.programId,
    required this.startTime,
    required this.remainingSets,
    this.selectedExerciseId,
    this.isResting = false,
    this.restTimeRemaining = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'program_id': programId,
      'start_time': startTime.toIso8601String(),
      'remaining_sets': remainingSets.entries.map((e) => '${e.key}:${e.value}').join(','),
      'selected_exercise_id': selectedExerciseId,
      'is_resting': isResting ? 1 : 0,
      'rest_time_remaining': restTimeRemaining,
    };
  }

  factory ActiveSession.fromMap(Map<String, dynamic> map) {
    Map<int, int> remainingSets = {};
    if (map['remaining_sets'] != null && map['remaining_sets'].toString().isNotEmpty) {
      final pairs = map['remaining_sets'].toString().split(',');
      for (var pair in pairs) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          remainingSets[int.parse(parts[0])] = int.parse(parts[1]);
        }
      }
    }

    return ActiveSession(
      id: map['id'],
      userId: map['user_id'],
      programId: map['program_id'],
      startTime: DateTime.parse(map['start_time']),
      remainingSets: remainingSets,
      selectedExerciseId: map['selected_exercise_id'],
      isResting: map['is_resting'] == 1,
      restTimeRemaining: map['rest_time_remaining'] ?? 0,
    );
  }
}
