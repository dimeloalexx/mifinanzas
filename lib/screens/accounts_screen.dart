import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/empty_state.dart';
import 'add_account_screen.dart';
import 'add_transfer_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  IconData _iconFor(AccountType type) {
    switch (type) {
      case AccountType.efectivo:
        return Icons.payments;
      case AccountType.banco:
        return Icons.account_balance;
      case AccountType.tarjeta:
        return Icons.credit_card;
      case AccountType.ahorro:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuentas y ahorros'),
        actions: [
          if (finance.accounts.length >= 2)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              tooltip: 'Transferir entre cuentas',
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AddTransferScreen())),
            ),
        ],
      ),
      body: finance.accounts.isEmpty
          ? const EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              color: AppColors.primary,
              message: 'Agrega tu primera cuenta con el botón +',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finance.accounts.length,
              itemBuilder: (context, index) {
                final account = finance.accounts[index];
                final balance = finance.balanceOf(account);
                final goal = account.savingsGoal;
                final progress = (goal != null && goal > 0) ? (balance / goal).clamp(0, 1).toDouble() : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AddAccountScreen(existing: account))),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              child: Icon(_iconFor(account.type)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(account.typeLabel, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormat.format(balance),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(context, finance, account.id),
                            ),
                          ],
                        ),
                        if (progress != null) ...[
                          const SizedBox(height: 12),
                          AnimatedProgressBar(progress: progress, color: AppColors.goal),
                          const SizedBox(height: 4),
                          Text(
                            'Meta: ${currencyFormat.format(goal)} (${(progress * 100).toStringAsFixed(0)}%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddAccountScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FinanceProvider finance, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('Se eliminará la cuenta y todos sus movimientos. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              finance.deleteAccount(id);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
