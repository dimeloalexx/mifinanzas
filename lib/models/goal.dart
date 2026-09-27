class Goal {
  final String id;
  final String name;
  final double targetAmount;
  final DateTime? deadline;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.deadline,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'deadline': deadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      name: map['name'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      deadline: map['deadline'] == null ? null : DateTime.parse(map['deadline'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class GoalContribution {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String note;

  GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory GoalContribution.fromMap(Map<String, dynamic> map) {
    return GoalContribution(
      id: map['id'] as String,
      goalId: map['goalId'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String? ?? '',
    );
  }
}
