import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  DateTime? _deadline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva meta')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: '¿Qué quieres lograr?',
                hintText: 'Ej. Viaje a Cancún, Fondo de emergencia',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto que quieres reunir', prefixText: '\$ '),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Ingresa un monto válido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha límite (opcional)'),
              subtitle: Text(_deadline == null ? 'Sin fecha límite' : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_deadline != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _deadline = null),
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _deadline = picked);
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Guardar meta'),
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
    await finance.addGoal(
      name: _nameCtrl.text.trim(),
      targetAmount: double.parse(_targetCtrl.text),
      deadline: _deadline,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }
}
