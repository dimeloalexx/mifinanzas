class Debt {
  final String id;
  final String name;
  final double totalAmount;
  final String note;
  final DateTime createdAt;

  Debt({
    required this.id,
    required this.name,
    required this.totalAmount,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as String,
      name: map['name'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class DebtPayment {
  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String note;

  DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'debtId': debtId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory DebtPayment.fromMap(Map<String, dynamic> map) {
    return DebtPayment(
      id: map['id'] as String,
      debtId: map['debtId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }
}
