import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/transaction_item.dart';
import '../providers/finance_provider.dart';
import 'new_category_dialog.dart';

const _newCategorySentinel = '__new_category__';

class AddTransactionScreen extends StatefulWidget {
  final TransactionItem? existing;

  const AddTransactionScreen({super.key, this.existing});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _amountCtrl = TextEditingController(
      text: widget.existing != null ? widget.existing!.amount.toStringAsFixed(2) : '');
  late final _noteCtrl = TextEditingController(text: widget.existing?.note ?? '');

  late CategoryKind _kind = widget.existing?.kind ?? CategoryKind.gasto;
  late String? _accountId = widget.existing?.accountId;
  late String? _category = widget.existing?.category;
  late DateTime _date = widget.existing?.date ?? DateTime.now();

  bool get _isEditing => widget.existing != null;

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    _accountId ??= finance.accounts.isNotEmpty ? finance.accounts.first.id : null;
    final categories = finance.categoriesForKind(_kind);
    _category ??= categories.isNotEmpty ? categories.first.name : null;
    if (!categories.any((c) => c.name == _category)) {
      _category = categories.isNotEmpty ? categories.first.name : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar movimiento' : 'Nuevo movimiento'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await finance.deleteTransaction(widget.existing!.id);
                if (mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
      body: finance.accounts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Primero crea una cuenta en la pestaña "Cuentas" para poder registrar movimientos.',
                    textAlign: TextAlign.center),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SegmentedButton<CategoryKind>(
                    segments: const [
                      ButtonSegment(value: CategoryKind.gasto, label: Text('Gasto'), icon: Icon(Icons.arrow_downward)),
                      ButtonSegment(value: CategoryKind.ingreso, label: Text('Ingreso'), icon: Icon(Icons.arrow_upward)),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (s) => setState(() {
                      _kind = s.first;
                      _category = null;
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Monto', prefixText: '\$ '),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return 'Ingresa un monto válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _accountId,
                    decoration: const InputDecoration(labelText: 'Cuenta'),
                    items: finance.accounts
                        .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _accountId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: [
                      ...categories.map((c) => DropdownMenuItem(
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
                          builder: (_) => NewCategoryDialog(kind: _kind),
                        );
                        if (created != null) setState(() => _category = created);
                      } else {
                        setState(() => _category = v);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fecha'),
                    subtitle: Text('${_date.day}/${_date.month}/${_date.year}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  ),
                  TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(labelText: 'Nota (opcional)'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submit,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_isEditing ? 'Guardar cambios' : 'Guardar movimiento'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_accountId == null || _category == null) return;
    final finance = context.read<FinanceProvider>();
    if (_isEditing) {
      await finance.updateTransaction(
        id: widget.existing!.id,
        accountId: _accountId!,
        category: _category!,
        kind: _kind,
        amount: double.parse(_amountCtrl.text),
        date: _date,
        note: _noteCtrl.text.trim(),
      );
    } else {
      await finance.addTransaction(
        accountId: _accountId!,
        category: _category!,
        kind: _kind,
        amount: double.parse(_amountCtrl.text),
        date: _date,
        note: _noteCtrl.text.trim(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
