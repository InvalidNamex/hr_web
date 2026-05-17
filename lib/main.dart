import 'package:flutter/material.dart';
import 'main_io.dart' if (dart.library.html) 'main_web.dart';
import 'di.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureHttpOverrides();

  await getIt.init();
  runApp(const App());
}
