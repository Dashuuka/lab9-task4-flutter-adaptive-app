import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task4_flutter_adaptive_app/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<dynamic> box;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('task4_integration_hive_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<dynamic>('lab9_cache');
  });

  setUp(() async {
    await box.clear();
    await box.put('language', 'en');
  });

  tearDownAll(() async {
    await box.close();
    tempDir.deleteSync(recursive: true);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: Lab9AdaptiveApp()));
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'student@example.com');
    await tester.enterText(find.byType(TextField).last, '123456');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
  }

  testWidgets('integration: user logs in and sees dashboard', (tester) async {
    await pumpApp(tester);
    await signIn(tester);

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Cars'), findsWidgets);
  });

  testWidgets('integration: user adds a car through UI', (tester) async {
    await pumpApp(tester);
    await signIn(tester);

    await tester.tap(find.text('Cars').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Skoda');
    await tester.enterText(find.byType(TextField).at(1), 'Octavia');
    await tester.enterText(find.byType(TextField).at(2), '65');
    await tester.enterText(find.byType(TextField).at(3), 'Vitebsk');
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(find.text('Skoda Octavia'), findsOneWidget);
  });

  testWidgets('integration: user opens details and deletes a car', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester);

    await tester.tap(find.text('Cars').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Toyota Camry'));
    await tester.pumpAndSettle();
    expect(find.text('85.00 BYN/day'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Toyota Camry'), findsNothing);
  });
}
