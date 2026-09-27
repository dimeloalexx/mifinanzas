import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/budget.dart';
import '../providers/finance_provider.dart';
import '../utils/formatters.dart';
import '../widgets/animated_progress_bar.dart';
import '../widgets/empty_state.dart';
import 'add_budget_screen.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text('Presupuestos · ${monthShortFormat.format(now)}')),
      body: finance.budgets.isEmpty
          ? const EmptyState(
              icon: Icons.pie_chart_outline,
              color: Colors.deepPurple,
              message: 'Agrega un presupuesto por categoría con el botón + y no te pases de la raya.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finance.budgets.length,
              itemBuilder: (context, index) {
                final budget = finance.budgets[index];
                final cat = finance.categoryFor(budget.category);
                final spent = finance.spentOnCategory(budget.category, now);
                final progress = budget.limit > 0 ? (spent / budget.limit).clamp(0, 1).toDouble() : 0.0;
                final over = spent > budget.limit;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _editBudgetLimit(context, finance, budget),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: cat.color.withValues(alpha: 0.15),
                                child: Icon(cat.icon, color: cat.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(budget.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => finance.deleteBudget(budget.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AnimatedProgressBar(
                            progress: progress,
                            color: over ? Colors.red : cat.color,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${currencyFormat.format(spent)} de ${currencyFormat.format(budget.limit)}'
                            '${over ? ' · ¡Límite superado!' : ''}',
                            style: TextStyle(
                              color: over ? Colors.red.shade700 : null,
                              fontWeight: over ? FontWeight.bold : null,
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
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddBudgetScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editBudgetLimit(BuildContext context, FinanceProvider finance, Budget budget) {
    final ctrl = TextEditingController(text: budget.limit.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar límite · ${budget.category}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Límite mensual', prefixText: '\$ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(ctrl.text);
              if (value != null && value > 0) {
                finance.updateBudget(Budget(id: budget.id, category: budget.category, limit: value));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
