import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../db/database_helper.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/debt.dart';
import '../models/goal.dart';
import '../models/transaction_item.dart';
import '../models/transfer.dart';

class FinanceProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  List<Account> accounts = [];
  List<TransactionItem> transactions = [];
  List<Budget> budgets = [];
  List<Goal> goals = [];
  List<GoalContribution> goalContributions = [];
  List<Debt> debts = [];
  List<DebtPayment> debtPayments = [];
  List<CustomCategory> customCategories = [];
  List<Transfer> transfers = [];
  bool loading = true;

  Future<void> load() async {
    loading = true;
    notifyListeners();
    accounts = await _db.getAccounts();
    transactions = await _db.getTransactions();
    budgets = await _db.getBudgets();
    goals = await _db.getGoals();
    goalContributions = await _db.getGoalContributions();
    debts = await _db.getDebts();
    debtPayments = await _db.getDebtPayments();
    customCategories = await _db.getCustomCategories();
    transfers = await _db.getTransfers();
    loading = false;
    notifyListeners();
  }

  // ---- Accounts ----
  double balanceOf(Account account) {
    final delta = transactions
        .where((t) => t.accountId == account.id)
        .fold<double>(0, (sum, t) => sum + t.signedAmount);
    final transfersOut = transfers
        .where((t) => t.fromAccountId == account.id)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final transfersIn = transfers
        .where((t) => t.toAccountId == account.id)
        .fold<double>(0, (sum, t) => sum + t.amount);
    return account.initialBalance + delta - transfersOut + transfersIn;
  }

  double get totalBalance =>
      accounts.fold<double>(0, (sum, a) => sum + balanceOf(a));

  Future<void> addAccount({
    required String name,
    required AccountType type,
    required double initialBalance,
    double? savingsGoal,
  }) async {
    final account = Account(
      id: _uuid.v4(),
      name: name,
      type: type,
      initialBalance: initialBalance,
      savingsGoal: savingsGoal,
    );
    await _db.insertAccount(account);
    accounts.add(account);
    notifyListeners();
  }

  Future<void> updateAccount({
    required String id,
    required String name,
    required AccountType type,
    required double initialBalance,
    double? savingsGoal,
  }) async {
    final account = Account(
      id: id,
      name: name,
      type: type,
      initialBalance: initialBalance,
      savingsGoal: savingsGoal,
    );
    await _db.updateAccount(account);
    final idx = accounts.indexWhere((a) => a.id == id);
    if (idx != -1) accounts[idx] = account;
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    await _db.deleteAccount(id);
    accounts.removeWhere((a) => a.id == id);
    transactions.removeWhere((t) => t.accountId == id);
    transfers.removeWhere((t) => t.fromAccountId == id || t.toAccountId == id);
    notifyListeners();
  }

  // ---- Transfers ----
  Future<void> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final transfer = Transfer(
      id: _uuid.v4(),
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      date: date,
      note: note,
    );
    await _db.insertTransfer(transfer);
    transfers.insert(0, transfer);
    transfers.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransfer(String id) async {
    await _db.deleteTransfer(id);
    transfers.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ---- Transactions ----
  Future<void> addTransaction({
    required String accountId,
    required String category,
    required CategoryKind kind,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final tx = TransactionItem(
      id: _uuid.v4(),
      accountId: accountId,
      category: category,
      kind: kind,
      amount: amount,
      date: date,
      note: note,
    );
    await _db.insertTransaction(tx);
    transactions.insert(0, tx);
    transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> updateTransaction({
    required String id,
    required String accountId,
    required String category,
    required CategoryKind kind,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final tx = TransactionItem(
      id: id,
      accountId: accountId,
      category: category,
      kind: kind,
      amount: amount,
      date: date,
      note: note,
    );
    await _db.updateTransaction(tx);
    final idx = transactions.indexWhere((t) => t.id == id);
    if (idx != -1) transactions[idx] = tx;
    transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  List<TransactionItem> get recentTransactions => transactions.take(5).toList();

  List<TransactionItem> transactionsInMonth(DateTime month) {
    return transactions
        .where((t) => t.date.year == month.year && t.date.month == month.month)
        .toList();
  }

  double totalForKind(CategoryKind kind, DateTime month) {
    return transactionsInMonth(month)
        .where((t) => t.kind == kind)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  Map<String, double> expensesByCategory(DateTime month) {
    final result = <String, double>{};
    for (final t in transactionsInMonth(month)) {
      if (t.kind != CategoryKind.gasto) continue;
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  // ---- Budgets ----
  Future<void> addBudget({required String category, required double limit}) async {
    final budget = Budget(id: _uuid.v4(), category: category, limit: limit);
    await _db.insertBudget(budget);
    budgets.add(budget);
    notifyListeners();
  }

  Future<void> updateBudget(Budget budget) async {
    await _db.updateBudget(budget);
    final idx = budgets.indexWhere((b) => b.id == budget.id);
    if (idx != -1) budgets[idx] = budget;
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(id);
    budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  double spentOnCategory(String category, DateTime month) {
    return transactionsInMonth(month)
        .where((t) => t.kind == CategoryKind.gasto && t.category == category)
        .fold<double>(0, (sum, t) => sum + t.amount);
  }

  // ---- Goals ----
  Future<void> addGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    final goal = Goal(
      id: _uuid.v4(),
      name: name,
      targetAmount: targetAmount,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    await _db.insertGoal(goal);
    goals.insert(0, goal);
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    await _db.deleteGoal(id);
    goals.removeWhere((g) => g.id == id);
    goalContributions.removeWhere((c) => c.goalId == id);
    notifyListeners();
  }

  Future<void> addGoalContribution({
    required String goalId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final contribution = GoalContribution(
      id: _uuid.v4(),
      goalId: goalId,
      amount: amount,
      date: date,
      note: note,
    );
    await _db.insertGoalContribution(contribution);
    goalContributions.insert(0, contribution);
    notifyListeners();
  }

  Future<void> deleteGoalContribution(String id) async {
    await _db.deleteGoalContribution(id);
    goalContributions.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  double goalSaved(Goal goal) {
    return goalContributions
        .where((c) => c.goalId == goal.id)
        .fold<double>(0, (sum, c) => sum + c.amount);
  }

  double goalProgress(Goal goal) {
    if (goal.targetAmount <= 0) return 0;
    return (goalSaved(goal) / goal.targetAmount).clamp(0, 1).toDouble();
  }

  List<GoalContribution> contributionsFor(String goalId) {
    return goalContributions.where((c) => c.goalId == goalId).toList();
  }

  // ---- Debts ----
  Future<void> addDebt({
    required String name,
    required double totalAmount,
    String note = '',
  }) async {
    final debt = Debt(
      id: _uuid.v4(),
      name: name,
      totalAmount: totalAmount,
      note: note,
      createdAt: DateTime.now(),
    );
    await _db.insertDebt(debt);
    debts.insert(0, debt);
    notifyListeners();
  }

  Future<void> deleteDebt(String id) async {
    await _db.deleteDebt(id);
    debts.removeWhere((d) => d.id == id);
    debtPayments.removeWhere((p) => p.debtId == id);
    notifyListeners();
  }

  Future<void> addDebtPayment({
    required String debtId,
    required double amount,
    required DateTime date,
    String note = '',
  }) async {
    final payment = DebtPayment(
      id: _uuid.v4(),
      debtId: debtId,
      amount: amount,
      date: date,
      note: note,
    );
    await _db.insertDebtPayment(payment);
    debtPayments.insert(0, payment);
    notifyListeners();
  }

  Future<void> deleteDebtPayment(String id) async {
    await _db.deleteDebtPayment(id);
    debtPayments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  double debtPaid(Debt debt) {
    return debtPayments
        .where((p) => p.debtId == debt.id)
        .fold<double>(0, (sum, p) => sum + p.amount);
  }

  double debtRemaining(Debt debt) {
    final remaining = debt.totalAmount - debtPaid(debt);
    return remaining < 0 ? 0 : remaining;
  }

  double debtProgress(Debt debt) {
    if (debt.totalAmount <= 0) return 0;
    return (debtPaid(debt) / debt.totalAmount).clamp(0, 1).toDouble();
  }

  List<DebtPayment> paymentsFor(String debtId) {
    return debtPayments.where((p) => p.debtId == debtId).toList();
  }

  // ---- Custom categories ----
  List<CategoryItem> categoriesForKind(CategoryKind kind) {
    return [
      ...defaultCategories.where((c) => c.kind == kind),
      ...customCategories.where((c) => c.kind == kind).map((c) => c.toCategoryItem()),
    ];
  }

  CategoryItem categoryFor(String name) {
    final custom = customCategories.where((c) => c.name == name);
    if (custom.isNotEmpty) return custom.first.toCategoryItem();
    return categoryByName(name);
  }

  Future<void> addCustomCategory({
    required String name,
    required CategoryKind kind,
    required String iconKey,
    required Color color,
  }) async {
    final category = CustomCategory(
      id: _uuid.v4(),
      name: name,
      kind: kind,
      iconKey: iconKey,
      colorValue: color.toARGB32(),
    );
    await _db.insertCustomCategory(category);
    customCategories.add(category);
    notifyListeners();
  }

  Future<void> deleteCustomCategory(String id) async {
    await _db.deleteCustomCategory(id);
    customCategories.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // ---- Backup ----
  Future<Map<String, dynamic>> exportBackup() => _db.exportAll();

  Future<void> restoreBackup(Map<String, dynamic> data) async {
    await _db.restoreAll(data);
    await load();
  }
}
