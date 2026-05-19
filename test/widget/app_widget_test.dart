import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:task4_flutter_adaptive_app/app/app.dart';
import 'package:task4_flutter_adaptive_app/core/l10n/app_localizations.dart';
import 'package:task4_flutter_adaptive_app/features/cars/car.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('task4_widget_hive_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('lab9_cache');
  });

  tearDown(() async {
    await box.clear();
  });

  tearDownAll(() async {
    await box.close();
    tempDir.deleteSync(recursive: true);
  });

  Widget localized(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  testWidgets('widget: login screen renders email password and button', (
    tester,
  ) async {
    await tester.pumpWidget(localized(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('widget: invalid login shows validation error', (tester) async {
    await tester.pumpWidget(localized(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'bad');
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pump();

    expect(find.text('Invalid email'), findsOneWidget);
  });

  testWidgets('widget: car card renders title address and favorite button', (
    tester,
  ) async {
    const car = Car(
      id: '1',
      brand: 'BMW',
      model: '320i',
      pricePerDay: 120,
      address: 'Brest, Sovetskaya 5',
      available: true,
    );

    await tester.pumpWidget(localized(const Scaffold(body: CarCard(car: car))));
    await tester.pumpAndSettle();

    expect(find.text('BMW 320i'), findsOneWidget);
    expect(find.text('Brest, Sovetskaya 5'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });
}
