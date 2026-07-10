import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's theme choice (system / light / dark).
class ThemeController extends Cubit<ThemeMode> {
  ThemeController(this._prefs) : super(_load(_prefs));

  static const _key = 'hairpredict.theme.v1';
  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    await _prefs.setString(_key, _encode(mode));
    emit(mode);
  }

  String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
