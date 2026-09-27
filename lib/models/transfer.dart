class Transfer {
  final String id;
  final String fromAccountId;
  final String toAccountId;
  final double amount;
  final DateTime date;
  final String note;

  Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Transfer.fromMap(Map<String, dynamic> map) {
    return Transfer(
      id: map['id'] as String,
      fromAccountId: map['fromAccountId'] as String,
      toAccountId: map['toAccountId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }
}
