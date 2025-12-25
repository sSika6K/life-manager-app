class Reminder {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final DateTime reminderTime;
  final bool isRecurring;
  final String? recurringPattern; // daily, weekly, monthly
  final bool isActive;
  final DateTime createdAt;

  Reminder({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.reminderTime,
    this.isRecurring = false,
    this.recurringPattern,
    this.isActive = true,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'reminder_time': reminderTime.toIso8601String(),
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_pattern': recurringPattern,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      reminderTime: DateTime.parse(map['reminder_time']),
      isRecurring: map['is_recurring'] == 1,
      recurringPattern: map['recurring_pattern'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
