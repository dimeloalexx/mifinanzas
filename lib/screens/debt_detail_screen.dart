import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/debt.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/animated_progress_bar.dart';

class DebtDetailScreen extends StatelessWidget {
  final Debt debt;

  const DebtDetailScreen({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final paid = finance.debtPaid(debt);
    final remaining = finance.debtRemaining(debt);
    final progress = finance.debtProgress(debt);
    final payments = finance.paymentsFor(debt.id);
    final settled = remaining <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(debt.name),
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
            color: AppColors.debt.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currencyFormat.format(remaining),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.debt)),
                  const Text('por pagar'),
                  const SizedBox(height: 12),
                  AnimatedProgressBar(progress: progress, color: AppColors.debt, height: 10),
                  const SizedBox(height: 8),
                  if (!settled)
                    Text('Pagado ${currencyFormat.format(paid)} de ${currencyFormat.format(debt.totalAmount)} (${(progress * 100).toStringAsFixed(0)}%)')
                  else
                    const Text('¡Deuda pagada por completo! 🎉', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (debt.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(debt.note),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Historial de pagos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Aún no has registrado pagos de esta deuda'),
            )
          else
            ...payments.map((p) => Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    color: Colors.red.shade400,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => finance.deleteDebtPayment(p.id),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.payments, color: AppColors.debt),
                      title: Text(currencyFormat.format(p.amount)),
                      subtitle: Text(
                        '${dateFormat.format(p.date)}${p.note.isNotEmpty ? ' · ${p.note}' : ''}',
                      ),
                    ),
                  ),
                )),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: settled
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddPaymentSheet(context, finance),
              icon: const Icon(Icons.add),
              label: const Text('Agregar pago'),
            ),
    );
  }

  void _confirmDelete(BuildContext context, FinanceProvider finance) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar deuda'),
        content: const Text('Se eliminará la deuda y todo su historial de pagos. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              finance.deleteDebt(debt.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentSheet(BuildContext context, FinanceProvider finance) {
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
              Text('Agregar pago', style: Theme.of(ctx).textTheme.titleMedium),
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
                  await finance.addDebtPayment(
                    debtId: debt.id,
                    amount: double.parse(amountCtrl.text),
                    date: DateTime.now(),
                    note: noteCtrl.text.trim(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Guardar pago'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
