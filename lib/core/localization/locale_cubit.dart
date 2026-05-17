import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/storage_service.dart';

part 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit(this._storage)
      : super(LocaleState(_storage.getLocale()));

  final StorageService _storage;

  void setLocale(Locale locale) {
    _storage.saveLocale(locale);
    emit(LocaleState(locale));
  }

  void toggleLocale() {
    final next = state.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    setLocale(next);
  }

  bool get isArabic => state.locale.languageCode == 'ar';
}
