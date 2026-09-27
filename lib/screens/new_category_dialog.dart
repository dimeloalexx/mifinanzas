import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/finance_provider.dart';

class NewCategoryDialog extends StatefulWidget {
  final CategoryKind kind;

  const NewCategoryDialog({super.key, required this.kind});

  @override
  State<NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  final _nameCtrl = TextEditingController();
  String _iconKey = customCategoryIcons.keys.first;
  Color _color = customCategoryColors.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoría'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            const Text('Ícono'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: customCategoryIcons.entries.map((entry) {
                final selected = entry.key == _iconKey;
                return InkWell(
                  onTap: () => setState(() => _iconKey = entry.key),
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    backgroundColor: selected ? _color : _color.withValues(alpha: 0.15),
                    child: Icon(entry.value, color: selected ? Colors.white : _color),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Color'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: customCategoryColors.map((c) {
                final selected = c.toARGB32() == _color.toARGB32();
                return InkWell(
                  onTap: () => setState(() => _color = c),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            final finance = context.read<FinanceProvider>();
            await finance.addCustomCategory(
              name: name,
              kind: widget.kind,
              iconKey: _iconKey,
              color: _color,
            );
            if (context.mounted) Navigator.pop(context, name);
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }
}
