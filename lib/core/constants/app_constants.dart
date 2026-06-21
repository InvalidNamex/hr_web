import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // static const String _localProxyUrl = 'http://localhost:8080';
  static const String _remoteUrl = 'https://192.168.100.203';
  // static const String _remoteUrl = 'https://natureccmpany.homeip.net:57571';

  /// Optional override with `--dart-define=API_BASE_URL=...`.
  ///
  /// Behavior when not provided:
  /// - Web debug on localhost: use local proxy to avoid CORS/cert issues.
  /// - Otherwise: use production API URL.
  static String get baseUrl {
    const definedBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (definedBaseUrl.isNotEmpty) {
      return definedBaseUrl;
    }

    // if (kIsWeb && !kReleaseMode && _isLocalHost(Uri.base.host)) {
    //   return _localProxyUrl;
    // }

    return _remoteUrl;
  }

  static bool _isLocalHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'localhost' || normalized == '127.0.0.1';
  }

  static const String serviceKey = '1111111';
  static const String tokenKey = 'jwt_token';
  static const String hrGroupIdKey = 'hr_group_id';
  static const String empIdKey = 'emp_id';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale_lang';

  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;

  static const int defaultPageSize = 10;
}
