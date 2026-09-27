enum AccountType { efectivo, banco, tarjeta, ahorro }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double initialBalance;
  final double? savingsGoal;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    this.savingsGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'initialBalance': initialBalance,
      'savingsGoal': savingsGoal,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as String,
      name: map['name'] as String,
      type: AccountType.values.firstWhere((e) => e.name == map['type']),
      initialBalance: (map['initialBalance'] as num).toDouble(),
      savingsGoal: map['savingsGoal'] == null
          ? null
          : (map['savingsGoal'] as num).toDouble(),
    );
  }

  String get typeLabel {
    switch (type) {
      case AccountType.efectivo:
        return 'Efectivo';
      case AccountType.banco:
        return 'Banco';
      case AccountType.tarjeta:
        return 'Tarjeta';
      case AccountType.ahorro:
        return 'Ahorro';
    }
  }
}
