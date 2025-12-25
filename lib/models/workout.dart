class Workout {
  final int? id;
  final int userId;
  final String name;
  final String description;
  final DateTime date;
  final int durationMinutes;
  final String? notes;

  Workout({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    DateTime? date,
    required this.durationMinutes,
    this.notes,
  }) : this.date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'date': date.toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      durationMinutes: map['duration_minutes'],
      notes: map['notes'],
    );
  }
}
