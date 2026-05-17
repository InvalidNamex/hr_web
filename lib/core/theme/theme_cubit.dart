import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/storage_service.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._storage)
      : super(ThemeState(_storage.getThemeMode()));

  final StorageService _storage;

  void toggleTheme() {
    final next =
        state.mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _storage.saveThemeMode(next);
    emit(ThemeState(next));
  }

  void setTheme(ThemeMode mode) {
    _storage.saveThemeMode(mode);
    emit(ThemeState(mode));
  }
}
