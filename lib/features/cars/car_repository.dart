import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/cache_service.dart';
import '../auth/auth_controller.dart';
import 'car.dart';

final carRepositoryProvider = Provider<CarRepository>((ref) {
  return CarRepository(ref.read(cacheProvider));
});

final carsProvider =
    StateNotifierProvider<CarsController, AsyncValue<List<Car>>>((ref) {
      return CarsController(ref.read(carRepositoryProvider))..load();
    });

class CarRepository {
  CarRepository(this._cache, {Dio? dio}) : _dio = dio ?? Dio();

  final CacheService _cache;
  final Dio _dio;

  Future<List<Car>> loadCars() async {
    try {
      // Fake API layer: Dio is kept here so the project has a replaceable HTTP boundary.
      _dio.options.baseUrl = 'https://example.invalid';
      final cached = _cache.get<List<dynamic>>('cars');
      if (cached != null && cached.isNotEmpty) {
        return cached
            .map((e) => Car.fromMap(Map<dynamic, dynamic>.from(e as Map)))
            .toList();
      }
      final seed = [
        const Car(
          id: '1',
          brand: 'Toyota',
          model: 'Camry',
          pricePerDay: 85,
          address: 'Minsk, Nezavisimosti 10',
          available: true,
        ),
        const Car(
          id: '2',
          brand: 'BMW',
          model: '320i',
          pricePerDay: 120,
          address: 'Brest, Sovetskaya 5',
          available: true,
        ),
        const Car(
          id: '3',
          brand: 'Volkswagen',
          model: 'Golf',
          pricePerDay: 70,
          address: 'Grodno, Zamkovaya 2',
          available: false,
        ),
      ];
      await saveCars(seed);
      return seed;
    } catch (e) {
      debugPrint('[CarRepository] load error: $e');
      rethrow;
    }
  }

  Future<void> saveCars(List<Car> cars) =>
      _cache.put('cars', cars.map((e) => e.toMap()).toList());
}

class CarsController extends StateNotifier<AsyncValue<List<Car>>> {
  CarsController(this._repository) : super(const AsyncValue.loading());

  final CarRepository _repository;

  Future<void> load() async {
    try {
      state = AsyncValue.data(await _repository.loadCars());
    } catch (e, st) {
      debugPrint('[CarsController] load error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addOrUpdate(Car car) async {
    final items = [...state.valueOrNull ?? <Car>[]];
    final index = items.indexWhere((e) => e.id == car.id);
    if (index >= 0) {
      items[index] = car;
    } else {
      items.add(car);
    }
    await _repository.saveCars(items);
    state = AsyncValue.data(items);
  }

  Future<void> delete(String id) async {
    final items = [...state.valueOrNull ?? <Car>[]]
      ..removeWhere((e) => e.id == id);
    await _repository.saveCars(items);
    state = AsyncValue.data(items);
  }

  Future<void> toggleFavorite(String id) async {
    final items = (state.valueOrNull ?? <Car>[]).map((car) {
      return car.id == id ? car.copyWith(favorite: !car.favorite) : car;
    }).toList();
    await _repository.saveCars(items);
    state = AsyncValue.data(items);
  }
}
