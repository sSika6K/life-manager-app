class WeeklySchedule {
  final int? id;
  final int userId;
  final int programId;
  final int dayOfWeek; // 1=Lundi, 7=Dimanche
  final DateTime createdAt;

  WeeklySchedule({
    this.id,
    required this.userId,
    required this.programId,
    required this.dayOfWeek,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'program_id': programId,
      'day_of_week': dayOfWeek,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WeeklySchedule.fromMap(Map<String, dynamic> map) {
    return WeeklySchedule(
      id: map['id'],
      userId: map['user_id'],
      programId: map['program_id'],
      dayOfWeek: map['day_of_week'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
