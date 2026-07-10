import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OnboardingStatus { incomplete, complete }

/// Tracks whether the user has completed onboarding.
class OnboardingCubit extends Cubit<OnboardingStatus> {
  OnboardingCubit(this._prefs) : super(OnboardingStatus.incomplete);

  static const _key = 'hairpredict.onboarding.v1';
  final SharedPreferences _prefs;

  Future<void> load() async {
    final saved = _prefs.getString(_key);
    if (saved == 'complete') {
      emit(OnboardingStatus.complete);
    }
  }

  Future<void> complete() async {
    await _prefs.setString(_key, 'complete');
    emit(OnboardingStatus.complete);
  }
}
