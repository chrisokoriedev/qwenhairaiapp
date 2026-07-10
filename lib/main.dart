import 'package:flutter/material.dart';

import 'package:qwenhairaiapp/app/app.dart';
import 'package:qwenhairaiapp/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const App());
}
