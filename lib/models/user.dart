class User {
  final int? id;
  final String username;
  final String password;
  final String? email;
  final String theme;
  final DateTime createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    this.email,
    this.theme = 'Deku',
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'theme': theme,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      theme: map['theme'] ?? 'Deku',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  User copyWith({
    int? id,
    String? username,
    String? password,
    String? email,
    String? theme,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
