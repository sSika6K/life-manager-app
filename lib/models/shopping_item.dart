class ShoppingItem {
  final int? id;
  final int userId;
  final String name;
  final String category;
  final int quantity;
  final bool isPurchased;
  final DateTime createdAt;

  ShoppingItem({
    this.id,
    required this.userId,
    required this.name,
    required this.category,
    this.quantity = 1,
    this.isPurchased = false,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'is_purchased': isPurchased ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      isPurchased: map['is_purchased'] == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  ShoppingItem copyWith({
    int? id,
    int? userId,
    String? name,
    String? category,
    int? quantity,
    bool? isPurchased,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isPurchased: isPurchased ?? this.isPurchased,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
