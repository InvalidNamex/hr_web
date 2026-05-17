class AppConstants {
  AppConstants._();

  static const String _remoteUrl = 'https://natureccmpany.homeip.net:57571';

  /// Override with `--dart-define=API_BASE_URL=...` when building.
  /// Defaults to the production API so hosted web builds do not point to localhost.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _remoteUrl,
  );

  static const String serviceKey = '1111111';
  static const String tokenKey = 'jwt_token';
  static const String hrGroupIdKey = 'hr_group_id';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale_lang';

  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;

  static const int defaultPageSize = 10;
}
