import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_ring.dart';
import 'add_goal_screen.dart';
import 'goal_detail_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      body: finance.goals.isEmpty
          ? const EmptyState(
              icon: Icons.flag_outlined,
              color: AppColors.goal,
              message: 'Crea una meta de ahorro con el botón + y ve tu progreso.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finance.goals.length,
              itemBuilder: (context, index) {
                final goal = finance.goals[index];
                final saved = finance.goalSaved(goal);
                final progress = finance.goalProgress(goal);
                final remaining = goal.targetAmount - saved;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => GoalDetailScreen(goal: goal))),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ProgressRing(
                                progress: progress,
                                color: AppColors.goal,
                                icon: Icons.flag,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(goal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (goal.deadline != null)
                                      Text('Meta para: ${dateFormat.format(goal.deadline!)}',
                                          style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.goal),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            remaining > 0
                                ? '${currencyFormat.format(saved)} de ${currencyFormat.format(goal.targetAmount)} · Faltan ${currencyFormat.format(remaining)}'
                                : '¡Meta completada! Ahorraste ${currencyFormat.format(saved)}',
                            style: TextStyle(
                              color: remaining <= 0 ? AppColors.goal : null,
                              fontWeight: remaining <= 0 ? FontWeight.bold : null,
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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
