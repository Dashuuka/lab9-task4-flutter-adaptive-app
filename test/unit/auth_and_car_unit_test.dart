import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:task4_flutter_adaptive_app/core/storage/cache_service.dart';
import 'package:task4_flutter_adaptive_app/features/auth/auth_controller.dart';
import 'package:task4_flutter_adaptive_app/features/cars/car.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('task4_unit_hive_');
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

  test('unit: auth validation rejects invalid email', () {
    expect(validateCredentials('bad-email', '123456'), 'invalidEmail');
  });

  test('unit: auth validation accepts valid credentials', () {
    expect(validateCredentials('student@example.com', '123456'), isNull);
  });

  test('unit: car serializes and restores business fields', () {
    const car = Car(
      id: '1',
      brand: 'Toyota',
      model: 'Camry',
      pricePerDay: 80,
      address: 'Minsk',
      available: true,
    );

    final restored = Car.fromMap(car.copyWith(favorite: true).toMap());
    expect(restored.title, 'Toyota Camry');
    expect(restored.favorite, isTrue);
  });

  test('unit: cache stores and reads session value', () async {
    final cache = CacheService(box);
    await cache.put('session_email', 'student@example.com');
    expect(cache.get<String>('session_email'), 'student@example.com');
  });
}
