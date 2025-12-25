class Expense {
  final int? id;
  final int userId;
  final String category;
  final double amount;
  final String description;
  final DateTime date;

  Expense({
    this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.description,
    DateTime? date,
  }) : this.date = date ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      userId: map['user_id'],
      category: map['category'],
      amount: map['amount'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}
