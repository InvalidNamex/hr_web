import 'dart:io';

void configureHttpOverrides() {
  HttpOverrides.global = _TrustAllCertsOverride();
}

class _TrustAllCertsOverride extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
