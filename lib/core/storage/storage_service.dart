import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  StorageService._(this._prefs);

  final SharedPreferences _prefs;

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // ── Token ──────────────────────────────────────────────────────────────────
  String? getToken() => _prefs.getString(AppConstants.tokenKey);
  Future<void> saveToken(String token) =>
      _prefs.setString(AppConstants.tokenKey, token);
  Future<void> clearToken() => _prefs.remove(AppConstants.tokenKey);
  bool get hasToken => getToken() != null;

  // ── HR Group ───────────────────────────────────────────────────────────────
  String? getHrGroupId() => _prefs.getString(AppConstants.hrGroupIdKey);
  Future<void> saveHrGroupId(String id) =>
      _prefs.setString(AppConstants.hrGroupIdKey, id);
  Future<void> clearHrGroupId() => _prefs.remove(AppConstants.hrGroupIdKey);

  // ── Employee ID ────────────────────────────────────────────────────────────
  int getEmpId() => _prefs.getInt(AppConstants.empIdKey) ?? 0;
  Future<void> saveEmpId(int id) => _prefs.setInt(AppConstants.empIdKey, id);
  Future<void> clearEmpId() => _prefs.remove(AppConstants.empIdKey);

  // ── Theme ──────────────────────────────────────────────────────────────────
  ThemeMode getThemeMode() {
    final value = _prefs.getString(AppConstants.themeKey);
    return value == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) => _prefs.setString(
    AppConstants.themeKey,
    mode == ThemeMode.dark ? 'dark' : 'light',
  );

  // ── Locale ─────────────────────────────────────────────────────────────────
  Locale getLocale() {
    final lang = _prefs.getString(AppConstants.localeKey) ?? 'en';
    return Locale(lang);
  }

  Future<void> saveLocale(Locale locale) =>
      _prefs.setString(AppConstants.localeKey, locale.languageCode);
}
