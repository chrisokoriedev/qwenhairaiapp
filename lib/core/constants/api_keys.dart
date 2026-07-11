/// API keys and secrets for HairPredict.
///
/// Keys are provided at compile-time via `--dart-define` or at
/// build-time via `--dart-define-from-file=.env`.
///
/// Never hardcode production keys in source code!
class ApiKeys {
  ApiKeys._();

  /// Qwen Cloud (DashScope) API key.
  ///
  /// Set via `--dart-define=QWEN_CLOUD_API_KEY=sk-xxx` when running or building.
  /// If using a .env file: `flutter run --dart-define-from-file=.env`
  static String get qwenCloudApiKey {
    const key = String.fromEnvironment('QWEN_CLOUD_API_KEY');
    if (key.isEmpty) {
      throw StateError(
        '\n\n⚠️  QWEN_CLOUD_API_KEY is not set!\n'
        '\n'
        'To run the app:\n'
        '  1. Copy .env.example to .env and fill in your key\n'
        '  2. Run: flutter run --dart-define-from-file=.env\n'
        '\n'
        'Or pass the key directly:\n'
        '  flutter run --dart-define=QWEN_CLOUD_API_KEY=sk-xxx\n',
      );
    }
    return key;
  }
}
