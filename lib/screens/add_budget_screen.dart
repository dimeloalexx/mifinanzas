import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/finance_provider.dart';
import 'new_category_dialog.dart';

const _newCategorySentinel = '__new_category__';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitCtrl = TextEditingController();
  String? _category;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final usedCategories = finance.budgets.map((b) => b.category).toSet();
    final expenseCategories = finance
        .categoriesForKind(CategoryKind.gasto)
        .where((c) => !usedCategories.contains(c.name))
        .toList();
    _category ??= expenseCategories.isNotEmpty ? expenseCategories.first.name : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo presupuesto')),
      body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: [
                      ...expenseCategories.map((c) => DropdownMenuItem(
                            value: c.name,
                            child: Row(
                              children: [
                                Icon(c.icon, color: c.color, size: 18),
                                const SizedBox(width: 8),
                                Text(c.name),
                              ],
                            ),
                          )),
                      const DropdownMenuItem(
                        value: _newCategorySentinel,
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 8),
                            Text('Nueva categoría'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (v) async {
                      if (v == _newCategorySentinel) {
                        final created = await showDialog<String>(
                          context: context,
                          builder: (_) => const NewCategoryDialog(kind: CategoryKind.gasto),
                        );
                        if (created != null) setState(() => _category = created);
                      } else {
                        setState(() => _category = v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _limitCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Límite mensual', prefixText: '\$ '),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Ingresa un monto válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Guardar presupuesto'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _category == null) return;
    final finance = context.read<FinanceProvider>();
    await finance.addBudget(category: _category!, limit: double.parse(_limitCtrl.text));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }
}
