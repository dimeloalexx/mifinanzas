import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_keypad.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String? _error;

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) {
      final settings = context.read<SettingsProvider>();
      if (settings.verifyPin(_pin)) {
        widget.onUnlocked();
      } else {
        setState(() {
          _error = 'PIN incorrecto';
          _pin = '';
        });
      }
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('Ingresa tu PIN', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? AppColors.primary : Colors.transparent,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 20,
              child: Text(_error ?? '', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            PinKeypad(onDigit: _onDigit, onBackspace: _onBackspace),
          ],
        ),
      ),
    );
  }
}
