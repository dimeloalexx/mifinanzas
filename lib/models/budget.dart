class Budget {
  final String id;
  final String category;
  final double limit;

  Budget({
    required this.id,
    required this.category,
    required this.limit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      category: map['category'] as String,
      limit: (map['limit'] as num).toDouble(),
    );
  }
}
