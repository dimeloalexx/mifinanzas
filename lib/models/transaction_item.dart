import 'category.dart';

class TransactionItem {
  final String id;
  final String accountId;
  final String category;
  final CategoryKind kind;
  final double amount;
  final DateTime date;
  final String note;

  TransactionItem({
    required this.id,
    required this.accountId,
    required this.category,
    required this.kind,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'category': category,
      'kind': kind.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as String,
      accountId: map['accountId'] as String,
      category: map['category'] as String,
      kind: CategoryKind.values.firstWhere((e) => e.name == map['kind']),
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }

  double get signedAmount => kind == CategoryKind.ingreso ? amount : -amount;
}
