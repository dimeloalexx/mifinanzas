import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction_item.dart';
import '../models/transfer.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final items = <dynamic>[...finance.transactions, ...finance.transfers]
      ..sort((a, b) {
        final DateTime da = a is TransactionItem ? a.date : (a as Transfer).date;
        final DateTime db = b is TransactionItem ? b.date : (b as Transfer).date;
        return db.compareTo(da);
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              color: AppColors.primary,
              message: 'Aún no hay movimientos registrados',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item is Transfer) {
                  return _TransferTile(transfer: item, finance: finance);
                }
                final t = item as TransactionItem;
                final cat = finance.categoryFor(t.category);
                final isIncome = t.kind == CategoryKind.ingreso;
                final accountMatches = finance.accounts.where((a) => a.id == t.accountId);
                final account = accountMatches.isEmpty ? null : accountMatches.first;
                return Dismissible(
                  key: ValueKey(t.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red.shade400,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => finance.deleteTransaction(t.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddTransactionScreen(existing: t))),
                      leading: CircleAvatar(
                        backgroundColor: cat.color.withValues(alpha: 0.15),
                        child: Icon(cat.icon, color: cat.color),
                      ),
                      title: Text(t.category),
                      subtitle: Text(
                        '${account?.name ?? ''} · ${dateFormat.format(t.date)}'
                        '${t.note.isNotEmpty ? '\n${t.note}' : ''}',
                      ),
                      isThreeLine: t.note.isNotEmpty,
                      trailing: Text(
                        '${isIncome ? '+' : '-'}${currencyFormat.format(t.amount)}',
                        style: TextStyle(
                          color: isIncome ? AppColors.income : AppColors.expense,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  final Transfer transfer;
  final FinanceProvider finance;

  const _TransferTile({required this.transfer, required this.finance});

  @override
  Widget build(BuildContext context) {
    final fromMatches = finance.accounts.where((a) => a.id == transfer.fromAccountId);
    final toMatches = finance.accounts.where((a) => a.id == transfer.toAccountId);
    final fromName = fromMatches.isEmpty ? '?' : fromMatches.first.name;
    final toName = toMatches.isEmpty ? '?' : toMatches.first.name;

    return Dismissible(
      key: ValueKey(transfer.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => finance.deleteTransfer(transfer.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueGrey.withValues(alpha: 0.15),
            child: const Icon(Icons.swap_horiz, color: Colors.blueGrey),
          ),
          title: Text('$fromName → $toName'),
          subtitle: Text(
            'Transferencia · ${dateFormat.format(transfer.date)}'
            '${transfer.note.isNotEmpty ? '\n${transfer.note}' : ''}',
          ),
          isThreeLine: transfer.note.isNotEmpty,
          trailing: Text(
            currencyFormat.format(transfer.amount),
            style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
