import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/finance_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'pin_setup_screen.dart';
import 'verify_pin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Apariencia'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Claro'),
                  secondary: const Icon(Icons.light_mode_outlined),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Oscuro'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Igual que el sistema'),
                  secondary: const Icon(Icons.brightness_auto_outlined),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (v) => settings.setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('Seguridad'),
          Card(
            child: SwitchListTile(
              title: const Text('Bloqueo con PIN'),
              subtitle: const Text('Pide un PIN de 4 dígitos al abrir la app'),
              secondary: const Icon(Icons.lock_outline),
              value: settings.pinEnabled,
              onChanged: (enable) async {
                if (enable) {
                  await Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const PinSetupScreen()));
                } else {
                  final verified = await Navigator.push<bool>(
                      context, MaterialPageRoute(builder: (_) => const VerifyPinScreen()));
                  if (verified == true) {
                    await settings.disablePin();
                  }
                }
              },
            ),
          ),
          if (settings.pinEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const PinSetupScreen())),
                icon: const Icon(Icons.password),
                label: const Text('Cambiar PIN'),
              ),
            ),
          const SizedBox(height: 24),
          _SectionTitle('Datos'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined, color: AppColors.primary),
                  title: const Text('Exportar respaldo'),
                  subtitle: const Text('Guarda todas tus cuentas, movimientos, metas y deudas en un archivo'),
                  onTap: () => _exportBackup(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download_outlined, color: AppColors.debt),
                  title: const Text('Restaurar respaldo'),
                  subtitle: const Text('Reemplaza los datos actuales con los de un archivo de respaldo'),
                  onTap: () => _importBackup(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final finance = context.read<FinanceProvider>();
    final data = await finance.exportBackup();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/finanzas_backup_$timestamp.json');
    await file.writeAsString(jsonEncode(data));
    if (!context.mounted) return;
    await Share.shareXFiles([XFile(file.path)], text: 'Respaldo de MiFinanzas');
  }

  Future<void> _importBackup(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restaurar respaldo'),
        content: const Text(
            'Esto reemplazará todos tus datos actuales con los del archivo que selecciones. ¿Continuar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continuar')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    if (!context.mounted) return;
    final finance = context.read<FinanceProvider>();
    await finance.restoreBackup(data);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos restaurados correctamente')),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
