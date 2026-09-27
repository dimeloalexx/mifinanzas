import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/animated_progress_bar.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final saved = finance.goalSaved(goal);
    final progress = finance.goalProgress(goal);
    final remaining = goal.targetAmount - saved;
    final contributions = finance.contributionsFor(goal.id);

    int? weeksLeft;
    double? suggestedPerWeek;
    if (goal.deadline != null && remaining > 0) {
      final days = goal.deadline!.difference(DateTime.now()).inDays;
      weeksLeft = (days / 7).ceil();
      if (weeksLeft < 1) weeksLeft = 1;
      suggestedPerWeek = remaining / weeksLeft;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, finance),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppColors.goal.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currencyFormat.format(saved),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.goal)),
                  Text('de ${currencyFormat.format(goal.targetAmount)}'),
                  const SizedBox(height: 12),
                  AnimatedProgressBar(progress: progress, color: AppColors.goal, height: 10),
                  const SizedBox(height: 8),
                  if (remaining > 0)
                    Text('Faltan ${currencyFormat.format(remaining)} (${(progress * 100).toStringAsFixed(0)}%)')
                  else
                    const Text('¡Meta completada! 🎉', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (goal.deadline != null) ...[
                    const SizedBox(height: 4),
                    Text('Fecha límite: ${dateFormat.format(goal.deadline!)}'),
                  ],
                  if (suggestedPerWeek != null) ...[
                    const SizedBox(height: 4),
                    Text('Sugerido: ${currencyFormat.format(suggestedPerWeek)} por semana'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Historial de abonos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (contributions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Aún no has agregado abonos a esta meta'),
            )
          else
            ...contributions.map((c) => Dismissible(
                  key: ValueKey(c.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red.shade400,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => finance.deleteGoalContribution(c.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.savings, color: AppColors.goal),
                      title: Text(currencyFormat.format(c.amount)),
                      subtitle: Text(
                        '${dateFormat.format(c.date)}${c.note.isNotEmpty ? ' · ${c.note}' : ''}',
                      ),
                    ),
                  ),
                )),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContributionSheet(context, finance),
        icon: const Icon(Icons.add),
        label: const Text('Agregar abono'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, FinanceProvider finance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar meta'),
        content: const Text('Se eliminará la meta y todo su historial de abonos. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              finance.deleteGoal(goal.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddContributionSheet(BuildContext context, FinanceProvider finance) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Agregar abono', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
                autofocus: true,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Ingresa un monto válido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Nota (opcional)'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  await finance.addGoalContribution(
                    goalId: goal.id,
                    amount: double.parse(amountCtrl.text),
                    date: DateTime.now(),
                    note: noteCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Guardar abono'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
