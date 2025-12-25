class Machine {
  final int? id;
  final int userId;
  final String name;
  final String? imagePath;
  final DateTime createdAt;

  Machine({
    this.id,
    required this.userId,
    required this.name,
    this.imagePath,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Machine.fromMap(Map<String, dynamic> map) {
    return Machine(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      imagePath: map['image_path'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
