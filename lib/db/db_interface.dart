import '../models/account.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/debt.dart';
import '../models/goal.dart';
import '../models/transaction_item.dart';
import '../models/transfer.dart';

abstract class IDatabaseHelper {
  Future<List<Account>> getAccounts();
  Future<void> insertAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);

  Future<List<TransactionItem>> getTransactions();
  Future<void> insertTransaction(TransactionItem tx);
  Future<void> updateTransaction(TransactionItem tx);
  Future<void> deleteTransaction(String id);

  Future<List<Budget>> getBudgets();
  Future<void> insertBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String id);

  Future<List<Goal>> getGoals();
  Future<void> insertGoal(Goal goal);
  Future<void> deleteGoal(String id);

  Future<List<GoalContribution>> getGoalContributions();
  Future<void> insertGoalContribution(GoalContribution contribution);
  Future<void> deleteGoalContribution(String id);

  Future<List<Debt>> getDebts();
  Future<void> insertDebt(Debt debt);
  Future<void> deleteDebt(String id);

  Future<List<DebtPayment>> getDebtPayments();
  Future<void> insertDebtPayment(DebtPayment payment);
  Future<void> deleteDebtPayment(String id);

  Future<List<CustomCategory>> getCustomCategories();
  Future<void> insertCustomCategory(CustomCategory category);
  Future<void> deleteCustomCategory(String id);

  Future<List<Transfer>> getTransfers();
  Future<void> insertTransfer(Transfer transfer);
  Future<void> deleteTransfer(String id);

  Future<Map<String, dynamic>> exportAll();
  Future<void> restoreAll(Map<String, dynamic> data);
}
