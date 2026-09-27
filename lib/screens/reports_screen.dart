import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final expenses = finance.expensesByCategory(_month);
    final totalExpenses = expenses.values.fold<double>(0, (a, b) => a + b);
    final ingresos = finance.totalForKind(CategoryKind.ingreso, _month);
    final gastos = finance.totalForKind(CategoryKind.gasto, _month);
    final sortedEntries = expenses.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
          ),
          Center(child: Text(monthFormat.format(_month))),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Ingresos',
                  value: currencyFormat.format(ingresos),
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Gastos',
                  value: currencyFormat.format(gastos),
                  color: AppColors.expense,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  label: 'Balance',
                  value: currencyFormat.format(ingresos - gastos),
                  color: (ingresos - gastos) >= 0 ? AppColors.income : AppColors.expense,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Tendencia (6 meses)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          _TrendChart(finance: finance, currentMonth: _month),
          const SizedBox(height: 24),
          Text('Gastos por categoría', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (totalExpenses == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: Text('No hay gastos registrados este mes')),
            )
          else ...[
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: sortedEntries.map((e) {
                    final cat = finance.categoryFor(e.key);
                    final pct = totalExpenses > 0 ? e.value / totalExpenses * 100 : 0;
                    return PieChartSectionData(
                      value: e.value,
                      color: cat.color,
                      title: '${pct.toStringAsFixed(0)}%',
                      radius: 60,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((e) {
              final cat = finance.categoryFor(e.key);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: cat.color),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.key)),
                    Text(currencyFormat.format(e.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final FinanceProvider finance;
  final DateTime currentMonth;

  const _TrendChart({required this.finance, required this.currentMonth});

  @override
  Widget build(BuildContext context) {
    final months = List.generate(6, (i) {
      final m = DateTime(currentMonth.year, currentMonth.month - (5 - i));
      return DateTime(m.year, m.month);
    });

    final maxValue = months.fold<double>(0, (max, m) {
      final inc = finance.totalForKind(CategoryKind.ingreso, m);
      final exp = finance.totalForKind(CategoryKind.gasto, m);
      return [max, inc, exp].reduce((a, b) => a > b ? a : b);
    });
    final chartMax = maxValue <= 0 ? 100.0 : maxValue * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= months.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              monthAbbrFormat.format(months[i]),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(months.length, (i) {
                    final inc = finance.totalForKind(CategoryKind.ingreso, months[i]);
                    final exp = finance.totalForKind(CategoryKind.gasto, months[i]);
                    return BarChartGroupData(
                      x: i,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: inc,
                          color: AppColors.income,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: exp,
                          color: AppColors.expense,
                          width: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.income, label: 'Ingresos'),
                const SizedBox(width: 20),
                _LegendDot(color: AppColors.expense, label: 'Gastos'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
