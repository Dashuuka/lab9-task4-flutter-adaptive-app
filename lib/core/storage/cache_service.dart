import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class CacheService {
  CacheService(this._box);

  final Box<dynamic> _box;

  T? get<T>(String key) {
    try {
      return _box.get(key) as T?;
    } catch (e) {
      debugPrint('[CacheService] get error: $e');
      return null;
    }
  }

  Future<void> put(String key, Object? value) async {
    try {
      await _box.put(key, value);
    } catch (e) {
      debugPrint('[CacheService] put error: $e');
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      await _box.clear();
    } catch (e) {
      debugPrint('[CacheService] clear error: $e');
      rethrow;
    }
  }
}
