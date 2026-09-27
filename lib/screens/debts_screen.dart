import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_ring.dart';
import 'add_debt_screen.dart';
import 'debt_detail_screen.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Deudas')),
      body: finance.debts.isEmpty
          ? const EmptyState(
              icon: Icons.credit_card_outlined,
              color: AppColors.debt,
              message: 'Registra una deuda con el botón + y controla lo que vas pagando.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finance.debts.length,
              itemBuilder: (context, index) {
                final debt = finance.debts[index];
                final paid = finance.debtPaid(debt);
                final remaining = finance.debtRemaining(debt);
                final progress = finance.debtProgress(debt);
                final settled = remaining <= 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => DebtDetailScreen(debt: debt))),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ProgressRing(
                                progress: progress,
                                color: AppColors.debt,
                                icon: Icons.credit_card,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(debt.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.debt),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            settled
                                ? '¡Deuda pagada por completo! Pagaste ${currencyFormat.format(paid)}'
                                : 'Pagado ${currencyFormat.format(paid)} de ${currencyFormat.format(debt.totalAmount)} · Restan ${currencyFormat.format(remaining)}',
                            style: TextStyle(
                              color: settled ? AppColors.income : null,
                              fontWeight: settled ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddDebtScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
