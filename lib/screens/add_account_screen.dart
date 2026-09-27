import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/account.dart';
import '../providers/finance_provider.dart';

class AddAccountScreen extends StatefulWidget {
  final Account? existing;

  const AddAccountScreen({super.key, this.existing});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
  late final _balanceCtrl =
      TextEditingController(text: (widget.existing?.initialBalance ?? 0).toStringAsFixed(2));
  late final _goalCtrl =
      TextEditingController(text: widget.existing?.savingsGoal?.toStringAsFixed(2) ?? '');

  late AccountType _type = widget.existing?.type ?? AccountType.efectivo;

  bool get _isEditing => widget.existing != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar cuenta' : 'Nueva cuenta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la cuenta'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo de cuenta'),
              items: AccountType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(_label(t))))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? AccountType.efectivo),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Saldo inicial', prefixText: '\$ '),
              validator: (v) => double.tryParse(v ?? '') == null ? 'Ingresa un monto válido' : null,
            ),
            if (_type == AccountType.ahorro) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Meta de ahorro (opcional)',
                  prefixText: '\$ ',
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_isEditing ? 'Guardar cambios' : 'Guardar cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(AccountType t) {
    switch (t) {
      case AccountType.efectivo:
        return 'Efectivo';
      case AccountType.banco:
        return 'Banco';
      case AccountType.tarjeta:
        return 'Tarjeta';
      case AccountType.ahorro:
        return 'Ahorro';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final finance = context.read<FinanceProvider>();
    final goal = _type == AccountType.ahorro ? double.tryParse(_goalCtrl.text) : null;
    if (_isEditing) {
      await finance.updateAccount(
        id: widget.existing!.id,
        name: _nameCtrl.text.trim(),
        type: _type,
        initialBalance: double.parse(_balanceCtrl.text),
        savingsGoal: (goal != null && goal > 0) ? goal : null,
      );
    } else {
      await finance.addAccount(
        name: _nameCtrl.text.trim(),
        type: _type,
        initialBalance: double.parse(_balanceCtrl.text),
        savingsGoal: (goal != null && goal > 0) ? goal : null,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }
}
