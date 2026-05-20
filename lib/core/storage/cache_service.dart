import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class CacheService {
  CacheService(this._box);
  CacheService.memory() : _box = null;

  final Box<dynamic>? _box;
  final Map<String, Object?> _memory = <String, Object?>{};

  T? get<T>(String key) {
    try {
      return (_box?.get(key) ?? _memory[key]) as T?;
    } catch (e) {
      debugPrint('[CacheService] get error: $e');
      return null;
    }
  }

  Future<void> put(String key, Object? value) async {
    try {
      final box = _box;
      if (box == null) {
        _memory[key] = value;
      } else {
        await box.put(key, value);
      }
    } catch (e) {
      debugPrint('[CacheService] put error: $e');
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      final box = _box;
      if (box == null) {
        _memory.clear();
      } else {
        await box.clear();
      }
    } catch (e) {
      debugPrint('[CacheService] clear error: $e');
      rethrow;
    }
  }
}
