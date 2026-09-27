import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../utils/formatters.dart';

class AddTransferScreen extends StatefulWidget {
  const AddTransferScreen({super.key});

  @override
  State<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends State<AddTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String? _fromId;
  String? _toId;
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    _fromId ??= finance.accounts.isNotEmpty ? finance.accounts.first.id : null;
    _toId ??= finance.accounts.length > 1 ? finance.accounts[1].id : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Transferir entre cuentas')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _fromId,
              decoration: const InputDecoration(labelText: 'Desde'),
              items: finance.accounts
                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                  .toList(),
              onChanged: (v) => setState(() => _fromId = v),
            ),
            const SizedBox(height: 8),
            const Center(child: Icon(Icons.arrow_downward)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _toId,
              decoration: const InputDecoration(labelText: 'Hacia'),
              items: finance.accounts
                  .map((a) => DropdownMenuItem(value: a.id, child: Text(a.name)))
                  .toList(),
              onChanged: (v) => setState(() => _toId = v),
            ),
            const SizedBox(height: 16),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha'),
              subtitle: Text(dateFormat.format(_date)),
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
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Transferir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromId == null || _toId == null) return;
    if (_fromId == _toId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige dos cuentas diferentes')),
      );
      return;
    }
    final finance = context.read<FinanceProvider>();
    await finance.addTransfer(
      fromAccountId: _fromId!,
      toAccountId: _toId!,
      amount: double.parse(_amountCtrl.text),
      date: _date,
      note: _noteCtrl.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }
}
