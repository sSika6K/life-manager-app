class Bill {
  final int? id;
  final int userId;
  final String name;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String category;

  Bill({
    this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'is_paid': isPaid ? 1 : 0,
      'category': category,
    };
  }

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      amount: map['amount'],
      dueDate: DateTime.parse(map['due_date']),
      isPaid: map['is_paid'] == 1,
      category: map['category'],
    );
  }

  Bill copyWith({
    int? id,
    int? userId,
    String? name,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? category,
  }) {
    return Bill(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      category: category ?? this.category,
    );
  }
}
