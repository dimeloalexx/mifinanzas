import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/debt.dart';
import '../models/goal.dart';
import '../models/transaction_item.dart';
import '../models/transfer.dart';
import 'db_interface.dart';

class DatabaseHelper implements IDatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finanzas_personales.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            initialBalance REAL NOT NULL,
            savingsGoal REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            accountId TEXT NOT NULL,
            category TEXT NOT NULL,
            kind TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE budgets (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            "limit" REAL NOT NULL
          )
        ''');
        await _createGoalsAndDebtsTables(db);
        await _createCategoriesAndTransfersTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createGoalsAndDebtsTables(db);
        }
        if (oldVersion < 3) {
          await _createCategoriesAndTransfersTables(db);
        }
      },
    );
  }

  Future<void> _createCategoriesAndTransfersTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS custom_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        kind TEXT NOT NULL,
        iconKey TEXT NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transfers (
        id TEXT PRIMARY KEY,
        fromAccountId TEXT NOT NULL,
        toAccountId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<void> _createGoalsAndDebtsTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goals (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        deadline TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS goal_contributions (
        id TEXT PRIMARY KEY,
        goalId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS debts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS debt_payments (
        id TEXT PRIMARY KEY,
        debtId TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // Accounts
  Future<List<Account>> getAccounts() async {
    final db = await database;
    final rows = await db.query('accounts');
    return rows.map((r) => Account.fromMap(r)).toList();
  }

  Future<void> insertAccount(Account account) async {
    final db = await database;
    await db.insert('accounts', account.toMap());
  }

  Future<void> updateAccount(Account account) async {
    final db = await database;
    await db.update('accounts', account.toMap(),
        where: 'id = ?', whereArgs: [account.id]);
  }

  Future<void> deleteAccount(String id) async {
    final db = await database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // Transactions
  Future<List<TransactionItem>> getTransactions() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'date DESC');
    return rows.map((r) => TransactionItem.fromMap(r)).toList();
  }

  Future<void> insertTransaction(TransactionItem tx) async {
    final db = await database;
    await db.insert('transactions', tx.toMap());
  }

  Future<void> updateTransaction(TransactionItem tx) async {
    final db = await database;
    await db.update('transactions', tx.toMap(), where: 'id = ?', whereArgs: [tx.id]);
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Budgets
  Future<List<Budget>> getBudgets() async {
    final db = await database;
    final rows = await db.query('budgets');
    return rows.map((r) => Budget.fromMap(r)).toList();
  }

  Future<void> insertBudget(Budget budget) async {
    final db = await database;
    await db.insert('budgets', budget.toMap());
  }

  Future<void> updateBudget(Budget budget) async {
    final db = await database;
    await db.update('budgets', budget.toMap(),
        where: 'id = ?', whereArgs: [budget.id]);
  }

  Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Goals
  Future<List<Goal>> getGoals() async {
    final db = await database;
    final rows = await db.query('goals', orderBy: 'createdAt DESC');
    return rows.map((r) => Goal.fromMap(r)).toList();
  }

  Future<void> insertGoal(Goal goal) async {
    final db = await database;
    await db.insert('goals', goal.toMap());
  }

  Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    await db.delete('goal_contributions', where: 'goalId = ?', whereArgs: [id]);
  }

  Future<List<GoalContribution>> getGoalContributions() async {
    final db = await database;
    final rows = await db.query('goal_contributions', orderBy: 'date DESC');
    return rows.map((r) => GoalContribution.fromMap(r)).toList();
  }

  Future<void> insertGoalContribution(GoalContribution contribution) async {
    final db = await database;
    await db.insert('goal_contributions', contribution.toMap());
  }

  Future<void> deleteGoalContribution(String id) async {
    final db = await database;
    await db.delete('goal_contributions', where: 'id = ?', whereArgs: [id]);
  }

  // Debts
  Future<List<Debt>> getDebts() async {
    final db = await database;
    final rows = await db.query('debts', orderBy: 'createdAt DESC');
    return rows.map((r) => Debt.fromMap(r)).toList();
  }

  Future<void> insertDebt(Debt debt) async {
    final db = await database;
    await db.insert('debts', debt.toMap());
  }

  Future<void> deleteDebt(String id) async {
    final db = await database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
    await db.delete('debt_payments', where: 'debtId = ?', whereArgs: [id]);
  }

  Future<List<DebtPayment>> getDebtPayments() async {
    final db = await database;
    final rows = await db.query('debt_payments', orderBy: 'date DESC');
    return rows.map((r) => DebtPayment.fromMap(r)).toList();
  }

  Future<void> insertDebtPayment(DebtPayment payment) async {
    final db = await database;
    await db.insert('debt_payments', payment.toMap());
  }

  Future<void> deleteDebtPayment(String id) async {
    final db = await database;
    await db.delete('debt_payments', where: 'id = ?', whereArgs: [id]);
  }

  // Custom categories
  Future<List<CustomCategory>> getCustomCategories() async {
    final db = await database;
    final rows = await db.query('custom_categories');
    return rows.map((r) => CustomCategory.fromMap(r)).toList();
  }

  Future<void> insertCustomCategory(CustomCategory category) async {
    final db = await database;
    await db.insert('custom_categories', category.toMap());
  }

  Future<void> deleteCustomCategory(String id) async {
    final db = await database;
    await db.delete('custom_categories', where: 'id = ?', whereArgs: [id]);
  }

  // Transfers
  Future<List<Transfer>> getTransfers() async {
    final db = await database;
    final rows = await db.query('transfers', orderBy: 'date DESC');
    return rows.map((r) => Transfer.fromMap(r)).toList();
  }

  Future<void> insertTransfer(Transfer transfer) async {
    final db = await database;
    await db.insert('transfers', transfer.toMap());
  }

  Future<void> deleteTransfer(String id) async {
    final db = await database;
    await db.delete('transfers', where: 'id = ?', whereArgs: [id]);
  }

  // Backup / restore
  Future<Map<String, dynamic>> exportAll() async {
    final db = await database;
    return {
      'accounts': await db.query('accounts'),
      'transactions': await db.query('transactions'),
      'budgets': await db.query('budgets'),
      'goals': await db.query('goals'),
      'goal_contributions': await db.query('goal_contributions'),
      'debts': await db.query('debts'),
      'debt_payments': await db.query('debt_payments'),
      'custom_categories': await db.query('custom_categories'),
      'transfers': await db.query('transfers'),
    };
  }

  Future<void> restoreAll(Map<String, dynamic> data) async {
    final db = await database;
    await db.transaction((txn) async {
      const tables = [
        'accounts',
        'transactions',
        'budgets',
        'goals',
        'goal_contributions',
        'debts',
        'debt_payments',
        'custom_categories',
        'transfers',
      ];
      for (final table in tables) {
        await txn.delete(table);
      }
      for (final table in tables) {
        final rows = (data[table] as List?) ?? [];
        for (final row in rows) {
          await txn.insert(table, Map<String, dynamic>.from(row as Map));
        }
      }
    });
  }
}
