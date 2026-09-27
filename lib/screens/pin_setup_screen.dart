import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_keypad.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _firstPin = '';
  String _pin = '';
  bool _confirming = false;
  String? _error;

  void _onDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _error = null;
    });
    if (_pin.length == 4) {
      if (!_confirming) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _confirming = true;
        });
      } else {
        if (_pin == _firstPin) {
          context.read<SettingsProvider>().setPin(_pin);
          Navigator.pop(context);
        } else {
          setState(() {
            _error = 'Los PIN no coinciden, intenta de nuevo';
            _pin = '';
            _confirming = false;
            _firstPin = '';
          });
        }
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
      appBar: AppBar(title: const Text('Configurar PIN')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            _confirming ? 'Confirma tu PIN' : 'Crea un PIN de 4 dígitos',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
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
    );
  }
}
