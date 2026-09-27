import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/debt.dart';
import '../models/goal.dart';
import '../models/transaction_item.dart';
import '../models/transfer.dart';
import 'db_interface.dart';

/// Web-only storage backed by shared_preferences (localStorage).
/// Avoids sqflite_common_ffi_web, whose SharedWorker-based implementation
/// is unreliable on iOS Safari.
class WebDatabaseHelper implements IDatabaseHelper {
  static final WebDatabaseHelper instance = WebDatabaseHelper._internal();
  WebDatabaseHelper._internal();

  static const _kAccounts = 'wdb_accounts';
  static const _kTransactions = 'wdb_transactions';
  static const _kBudgets = 'wdb_budgets';
  static const _kGoals = 'wdb_goals';
  static const _kGoalContributions = 'wdb_goal_contributions';
  static const _kDebts = 'wdb_debts';
  static const _kDebtPayments = 'wdb_debt_payments';
  static const _kCustomCategories = 'wdb_custom_categories';
  static const _kTransfers = 'wdb_transfers';

  Future<List<Map<String, dynamic>>> _readList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(rows));
  }

  // Accounts
  @override
  Future<List<Account>> getAccounts() async {
    final rows = await _readList(_kAccounts);
    return rows.map((r) => Account.fromMap(r)).toList();
  }

  @override
  Future<void> insertAccount(Account account) async {
    final rows = await _readList(_kAccounts);
    rows.add(account.toMap());
    await _writeList(_kAccounts, rows);
  }

  @override
  Future<void> updateAccount(Account account) async {
    final rows = await _readList(_kAccounts);
    final idx = rows.indexWhere((r) => r['id'] == account.id);
    if (idx != -1) rows[idx] = account.toMap();
    await _writeList(_kAccounts, rows);
  }

  @override
  Future<void> deleteAccount(String id) async {
    final rows = await _readList(_kAccounts);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kAccounts, rows);
  }

  // Transactions
  @override
  Future<List<TransactionItem>> getTransactions() async {
    final rows = await _readList(_kTransactions);
    final items = rows.map((r) => TransactionItem.fromMap(r)).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<void> insertTransaction(TransactionItem tx) async {
    final rows = await _readList(_kTransactions);
    rows.add(tx.toMap());
    await _writeList(_kTransactions, rows);
  }

  @override
  Future<void> updateTransaction(TransactionItem tx) async {
    final rows = await _readList(_kTransactions);
    final idx = rows.indexWhere((r) => r['id'] == tx.id);
    if (idx != -1) rows[idx] = tx.toMap();
    await _writeList(_kTransactions, rows);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final rows = await _readList(_kTransactions);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kTransactions, rows);
  }

  // Budgets
  @override
  Future<List<Budget>> getBudgets() async {
    final rows = await _readList(_kBudgets);
    return rows.map((r) => Budget.fromMap(r)).toList();
  }

  @override
  Future<void> insertBudget(Budget budget) async {
    final rows = await _readList(_kBudgets);
    rows.add(budget.toMap());
    await _writeList(_kBudgets, rows);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    final rows = await _readList(_kBudgets);
    final idx = rows.indexWhere((r) => r['id'] == budget.id);
    if (idx != -1) rows[idx] = budget.toMap();
    await _writeList(_kBudgets, rows);
  }

  @override
  Future<void> deleteBudget(String id) async {
    final rows = await _readList(_kBudgets);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kBudgets, rows);
  }

  // Goals
  @override
  Future<List<Goal>> getGoals() async {
    final rows = await _readList(_kGoals);
    final items = rows.map((r) => Goal.fromMap(r)).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> insertGoal(Goal goal) async {
    final rows = await _readList(_kGoals);
    rows.add(goal.toMap());
    await _writeList(_kGoals, rows);
  }

  @override
  Future<void> deleteGoal(String id) async {
    final rows = await _readList(_kGoals);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kGoals, rows);
    final contributions = await _readList(_kGoalContributions);
    contributions.removeWhere((r) => r['goalId'] == id);
    await _writeList(_kGoalContributions, contributions);
  }

  @override
  Future<List<GoalContribution>> getGoalContributions() async {
    final rows = await _readList(_kGoalContributions);
    final items = rows.map((r) => GoalContribution.fromMap(r)).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<void> insertGoalContribution(GoalContribution contribution) async {
    final rows = await _readList(_kGoalContributions);
    rows.add(contribution.toMap());
    await _writeList(_kGoalContributions, rows);
  }

  @override
  Future<void> deleteGoalContribution(String id) async {
    final rows = await _readList(_kGoalContributions);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kGoalContributions, rows);
  }

  // Debts
  @override
  Future<List<Debt>> getDebts() async {
    final rows = await _readList(_kDebts);
    final items = rows.map((r) => Debt.fromMap(r)).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<void> insertDebt(Debt debt) async {
    final rows = await _readList(_kDebts);
    rows.add(debt.toMap());
    await _writeList(_kDebts, rows);
  }

  @override
  Future<void> deleteDebt(String id) async {
    final rows = await _readList(_kDebts);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kDebts, rows);
    final payments = await _readList(_kDebtPayments);
    payments.removeWhere((r) => r['debtId'] == id);
    await _writeList(_kDebtPayments, payments);
  }

  @override
  Future<List<DebtPayment>> getDebtPayments() async {
    final rows = await _readList(_kDebtPayments);
    final items = rows.map((r) => DebtPayment.fromMap(r)).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<void> insertDebtPayment(DebtPayment payment) async {
    final rows = await _readList(_kDebtPayments);
    rows.add(payment.toMap());
    await _writeList(_kDebtPayments, rows);
  }

  @override
  Future<void> deleteDebtPayment(String id) async {
    final rows = await _readList(_kDebtPayments);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kDebtPayments, rows);
  }

  // Custom categories
  @override
  Future<List<CustomCategory>> getCustomCategories() async {
    final rows = await _readList(_kCustomCategories);
    return rows.map((r) => CustomCategory.fromMap(r)).toList();
  }

  @override
  Future<void> insertCustomCategory(CustomCategory category) async {
    final rows = await _readList(_kCustomCategories);
    rows.add(category.toMap());
    await _writeList(_kCustomCategories, rows);
  }

  @override
  Future<void> deleteCustomCategory(String id) async {
    final rows = await _readList(_kCustomCategories);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kCustomCategories, rows);
  }

  // Transfers
  @override
  Future<List<Transfer>> getTransfers() async {
    final rows = await _readList(_kTransfers);
    final items = rows.map((r) => Transfer.fromMap(r)).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  @override
  Future<void> insertTransfer(Transfer transfer) async {
    final rows = await _readList(_kTransfers);
    rows.add(transfer.toMap());
    await _writeList(_kTransfers, rows);
  }

  @override
  Future<void> deleteTransfer(String id) async {
    final rows = await _readList(_kTransfers);
    rows.removeWhere((r) => r['id'] == id);
    await _writeList(_kTransfers, rows);
  }

  // Backup / restore
  @override
  Future<Map<String, dynamic>> exportAll() async {
    return {
      'accounts': await _readList(_kAccounts),
      'transactions': await _readList(_kTransactions),
      'budgets': await _readList(_kBudgets),
      'goals': await _readList(_kGoals),
      'goal_contributions': await _readList(_kGoalContributions),
      'debts': await _readList(_kDebts),
      'debt_payments': await _readList(_kDebtPayments),
      'custom_categories': await _readList(_kCustomCategories),
      'transfers': await _readList(_kTransfers),
    };
  }

  @override
  Future<void> restoreAll(Map<String, dynamic> data) async {
    final map = {
      _kAccounts: 'accounts',
      _kTransactions: 'transactions',
      _kBudgets: 'budgets',
      _kGoals: 'goals',
      _kGoalContributions: 'goal_contributions',
      _kDebts: 'debts',
      _kDebtPayments: 'debt_payments',
      _kCustomCategories: 'custom_categories',
      _kTransfers: 'transfers',
    };
    for (final entry in map.entries) {
      final rows = (data[entry.value] as List?) ?? [];
      await _writeList(
          entry.key, rows.map((e) => Map<String, dynamic>.from(e as Map)).toList());
    }
  }
}
