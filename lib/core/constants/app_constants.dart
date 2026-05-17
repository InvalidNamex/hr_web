import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String _remoteUrl = 'https://natureccmpany.homeip.net:57571';
  static const String _proxyUrl = 'http://localhost:8080';

  /// On web, traffic goes through the local CORS proxy.
  /// On mobile/desktop, we connect directly (SSL override handles the cert).
  static String get baseUrl => kIsWeb ? _proxyUrl : _remoteUrl;

  static const String serviceKey = '1111111';
  static const String tokenKey = 'jwt_token';
  static const String hrGroupIdKey = 'hr_group_id';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale_lang';

  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;

  static const int defaultPageSize = 10;
}
