import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'di.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Accept self-signed certificates on mobile/desktop.
  // Has no effect on web (dart:io is unavailable there; the proxy handles it).
  if (!kIsWeb) {
    HttpOverrides.global = _TrustAllCertsOverride();
  }

  await getIt.init();
  runApp(const App());
}

class _TrustAllCertsOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
