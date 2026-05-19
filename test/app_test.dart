import 'package:flutter_test/flutter_test.dart';
import 'package:task4_flutter_adaptive_app/features/auth/auth_controller.dart';
import 'package:task4_flutter_adaptive_app/features/cars/car.dart';

void main() {
  test('auth validation catches invalid input', () {
    expect(validateCredentials('', ''), 'emptyFields');
    expect(validateCredentials('bad', '123456'), 'invalidEmail');
    expect(validateCredentials('a@b.com', '123'), 'shortPassword');
    expect(validateCredentials('a@b.com', '123456'), isNull);
  });

  test('car model supports CRUD-style copy and serialization', () {
    const car = Car(
      id: '1',
      brand: 'Toyota',
      model: 'Camry',
      pricePerDay: 80,
      address: 'Minsk',
      available: true,
    );
    final favorite = car.copyWith(favorite: true);
    expect(favorite.favorite, isTrue);
    expect(Car.fromMap(favorite.toMap()).title, 'Toyota Camry');
  });
}
