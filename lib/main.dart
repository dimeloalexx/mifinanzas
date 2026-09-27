import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/finance_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/lock_screen.dart';
import 'screens/root_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  runApp(const FinanzasApp());
}

class FinanzasApp extends StatelessWidget {
  const FinanzasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FinanceProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'MiFinanzas',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: settings.loading
                ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                : const _AppGate(),
          );
        },
      ),
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    if (settings.pinEnabled && !_unlocked) {
      return LockScreen(onUnlocked: () => setState(() => _unlocked = true));
    }
    return const RootScreen();
  }
}
