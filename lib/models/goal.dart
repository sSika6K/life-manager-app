class Goal {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final DateTime targetDate;
  final String category; // finance, fitness, study, personal
  final bool isCompleted;
  final int progress; // 0-100
  final DateTime createdAt;

  Goal({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.targetDate,
    required this.category,
    this.isCompleted = false,
    this.progress = 0,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'target_date': targetDate.toIso8601String(),
      'category': category,
      'is_completed': isCompleted ? 1 : 0,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      targetDate: DateTime.parse(map['target_date']),
      category: map['category'],
      isCompleted: map['is_completed'] == 1,
      progress: map['progress'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Goal copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? targetDate,
    String? category,
    bool? isCompleted,
    int? progress,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
