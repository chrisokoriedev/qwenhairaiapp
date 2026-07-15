import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/entities/scan_record.dart';

/// Manages the persisted list of past scans for the Home tab.
class ScanHistoryCubit extends Cubit<List<ScanRecord>> {
  ScanHistoryCubit(this._prefs) : super([]);

  final SharedPreferences _prefs;

  static const _key = 'hairpredict.scan_history.v1';

  /// Load persisted history from SharedPreferences.
  Future<void> load() async {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      emit([]);
      return;
    }
    try {
      final list = (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(ScanRecord.fromJson)
          .toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      emit(list);
    } catch (_) {
      emit([]);
    }
  }

  /// Add a record and persist.
  Future<void> addRecord(ScanRecord record) async {
    final updated = [record, ...state].take(50).toList();
    emit(updated);
    await _persist(updated);
  }

  /// Clear all history.
  Future<void> clearHistory() async {
    emit([]);
    await _persist([]);
  }

  Future<void> _persist(List<ScanRecord> records) async {
    await _prefs.setString(
      _key,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }
}
