import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';

class AddDebtScreen extends StatefulWidget {
  const AddDebtScreen({super.key});

  @override
  State<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva deuda')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre de la deuda',
                hintText: 'Ej. Tarjeta BBVA, Préstamo personal',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto total de la deuda', prefixText: '\$ '),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Ingresa un monto válido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Nota (opcional)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Guardar deuda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final finance = context.read<FinanceProvider>();
    await finance.addDebt(
      name: _nameCtrl.text.trim(),
      totalAmount: double.parse(_totalCtrl.text),
      note: _noteCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _totalCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
