import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyPinEnabled = 'pin_enabled';
  static const _keyPinHash = 'pin_hash';
  static const _keyPinSalt = 'pin_salt';

  ThemeMode themeMode = ThemeMode.system;
  bool pinEnabled = false;
  bool loading = true;

  String? _pinHash;
  String? _pinSalt;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyThemeMode);
    themeMode = switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    pinEnabled = prefs.getBool(_keyPinEnabled) ?? false;
    _pinHash = prefs.getString(_keyPinHash);
    _pinSalt = prefs.getString(_keyPinSalt);
    loading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_keyThemeMode, value);
  }

  String _hash(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }

  Future<void> setPin(String pin) async {
    final salt = List.generate(16, (_) => Random.secure().nextInt(256))
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final hash = _hash(pin, salt);
    _pinSalt = salt;
    _pinHash = hash;
    pinEnabled = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPinSalt, salt);
    await prefs.setString(_keyPinHash, hash);
    await prefs.setBool(_keyPinEnabled, true);
  }

  Future<void> disablePin() async {
    pinEnabled = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPinEnabled, false);
  }

  bool verifyPin(String pin) {
    if (_pinHash == null || _pinSalt == null) return false;
    return _hash(pin, _pinSalt!) == _pinHash;
  }
}
