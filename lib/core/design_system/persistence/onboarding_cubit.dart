import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../entities/hair_type.dart';

enum OnboardingStatus { incomplete, complete }

/// Tracks whether the user has completed onboarding and their profile options.
class OnboardingCubit extends Cubit<OnboardingStatus> {
  OnboardingCubit(this._prefs) : super(OnboardingStatus.incomplete);

  static const _key = 'hairpredict.onboarding.v1';
  static const _displayNameKey = 'hairpredict.onboarding.display_name.v1';
  static const _hairTypeKey = 'hairpredict.onboarding.hair_type.v1';

  final SharedPreferences _prefs;

  String? get displayName => _prefs.getString(_displayNameKey);

  HairType? get hairType {
    final saved = _prefs.getString(_hairTypeKey);
    if (saved == null) return null;
    for (final val in HairType.values) {
      if (val.name == saved) return val;
    }
    return null;
  }

  Future<void> load() async {
    final saved = _prefs.getString(_key);
    if (saved == 'complete') {
      emit(OnboardingStatus.complete);
    }
  }

  Future<void> complete(String displayName, HairType hairType) async {
    await _prefs.setString(_displayNameKey, displayName);
    await _prefs.setString(_hairTypeKey, hairType.name);
    await _prefs.setString(_key, 'complete');
    emit(OnboardingStatus.complete);
  }
}
