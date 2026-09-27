import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'add_transaction_screen.dart';
import 'debts_screen.dart';
import 'goals_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final now = DateTime.now();

    if (finance.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ingresos = finance.totalForKind(CategoryKind.ingreso, now);
    final gastos = finance.totalForKind(CategoryKind.gasto, now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MiFinanzas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: finance.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Balance total',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85))),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(finance.totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'Ingresos (mes)',
                            value: currencyFormat.format(ingresos),
                            icon: Icons.arrow_upward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MiniStat(
                            label: 'Gastos (mes)',
                            value: currencyFormat.format(gastos),
                            icon: Icons.arrow_downward,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _QuickAccessCard(
                    label: 'Metas',
                    icon: Icons.flag,
                    color: AppColors.goal,
                    subtitle: finance.goals.isEmpty
                        ? 'Crea tu primera meta'
                        : '${finance.goals.length} activa(s)',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const GoalsScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAccessCard(
                    label: 'Deudas',
                    icon: Icons.credit_card,
                    color: AppColors.debt,
                    subtitle: finance.debts.isEmpty
                        ? 'Registra una deuda'
                        : '${finance.debts.length} registrada(s)',
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const DebtsScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Movimientos recientes',
                    style: Theme.of(context).textTheme.titleMedium),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TransactionsScreen())),
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            if (finance.recentTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Aún no hay movimientos registrados')),
              )
            else
              ...finance.recentTransactions.map((t) {
                final cat = finance.categoryFor(t.category);
                final isIncome = t.kind == CategoryKind.ingreso;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AddTransactionScreen(existing: t))),
                    leading: CircleAvatar(
                      backgroundColor: cat.color.withValues(alpha: 0.15),
                      child: Icon(cat.icon, color: cat.color),
                    ),
                    title: Text(t.category),
                    subtitle: Text(dateFormat.format(t.date)),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}${currencyFormat.format(t.amount)}',
                      style: TextStyle(
                        color: isIncome ? AppColors.income : AppColors.expense,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo movimiento'),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
