import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('ru'), Locale('en'), Locale('be')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  static const _values = {
    'ru': {
      'app': 'Аренда авто',
      'email': 'Email',
      'password': 'Пароль',
      'login': 'Войти',
      'logout': 'Выйти',
      'cars': 'Автомобили',
      'home': 'Главная',
      'settings': 'Настройки',
      'add': 'Добавить',
      'edit': 'Редактировать',
      'delete': 'Удалить',
      'favorite': 'Избранное',
      'details': 'Детали',
      'theme': 'Тема',
      'language': 'Язык',
      'clearCache': 'Очистить кеш',
      'version': 'Версия 1.0.0',
      'invalidEmail': 'Неверный email',
      'shortPassword': 'Пароль минимум 6 символов',
      'emptyFields': 'Заполните поля',
    },
    'en': {
      'app': 'Car rental',
      'email': 'Email',
      'password': 'Password',
      'login': 'Sign in',
      'logout': 'Logout',
      'cars': 'Cars',
      'home': 'Home',
      'settings': 'Settings',
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'favorite': 'Favorite',
      'details': 'Details',
      'theme': 'Theme',
      'language': 'Language',
      'clearCache': 'Clear cache',
      'version': 'Version 1.0.0',
      'invalidEmail': 'Invalid email',
      'shortPassword': 'Password must contain 6 characters',
      'emptyFields': 'Fill all fields',
    },
    'be': {
      'app': 'Арэнда аўто',
      'email': 'Email',
      'password': 'Пароль',
      'login': 'Увайсці',
      'logout': 'Выйсці',
      'cars': 'Аўтамабілі',
      'home': 'Галоўная',
      'settings': 'Налады',
      'add': 'Дадаць',
      'edit': 'Рэдагаваць',
      'delete': 'Выдаліць',
      'favorite': 'Абранае',
      'details': 'Дэталі',
      'theme': 'Тэма',
      'language': 'Мова',
      'clearCache': 'Ачысціць кеш',
      'version': 'Версія 1.0.0',
      'invalidEmail': 'Няправільны email',
      'shortPassword': 'Пароль мінімум 6 сімвалаў',
      'emptyFields': 'Запоўніце палі',
    },
  };

  String t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['ru']![key] ?? key;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ru', 'en', 'be'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
