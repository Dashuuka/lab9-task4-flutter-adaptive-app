import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
      return SettingsController(ref.read(cacheProvider))..restore();
    });

class SettingsState {
  const SettingsState({
    this.locale = const Locale('ru'),
    this.themeMode = ThemeMode.system,
  });

  final Locale locale;
  final ThemeMode themeMode;

  SettingsState copyWith({Locale? locale, ThemeMode? themeMode}) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._cache) : super(const SettingsState());

  final dynamic _cache;

  void restore() {
    final lang = _cache.get<String>('language') ?? 'ru';
    final theme = _cache.get<String>('theme') ?? 'system';
    state = SettingsState(
      locale: Locale(lang),
      themeMode: _themeFromString(theme),
    );
  }

  Future<void> setLocale(Locale locale) async {
    await _cache.put('language', locale.languageCode);
    state = state.copyWith(locale: locale);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _cache.put('theme', mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> clearCache() => _cache.clear();
}

ThemeMode _themeFromString(String value) {
  return ThemeMode.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ThemeMode.system,
  );
}
