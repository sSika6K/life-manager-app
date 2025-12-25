class Subscription {
  final int? id;
  final int userId;
  final String name;
  final double amount;
  final String frequency; // monthly, yearly, weekly
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  Subscription({
    this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.frequency,
    DateTime? startDate,
    this.endDate,
    this.isActive = true,
  }) : this.startDate = startDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'amount': amount,
      'frequency': frequency,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      amount: map['amount'],
      frequency: map['frequency'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isActive: map['is_active'] == 1,
    );
  }
}
