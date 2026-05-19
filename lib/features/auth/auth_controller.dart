import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/storage/cache_service.dart';

final cacheProvider = Provider<CacheService>(
  (ref) => CacheService(Hive.box<dynamic>('lab9_cache')),
);

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref.read(cacheProvider))..restore();
  },
);

class AuthState {
  const AuthState({this.email, this.error});

  final String? email;
  final String? error;
  bool get signedIn => email != null;

  AuthState copyWith({
    String? email,
    String? error,
    bool clearEmail = false,
    bool clearError = false,
  }) {
    return AuthState(
      email: clearEmail ? null : email ?? this.email,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._cache) : super(const AuthState());

  final CacheService _cache;

  void restore() {
    final email = _cache.get<String>('session_email');
    if (email != null && email.isNotEmpty) {
      state = AuthState(email: email);
    }
  }

  Future<bool> signIn(String email, String password) async {
    final error = validateCredentials(email, password);
    if (error != null) {
      state = state.copyWith(error: error);
      return false;
    }
    try {
      await _cache.put('session_email', email.trim());
      state = AuthState(email: email.trim());
      return true;
    } catch (e) {
      debugPrint('[AuthController] signIn error: $e');
      state = state.copyWith(error: 'cache_error');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _cache.put('session_email', '');
    } catch (e) {
      debugPrint('[AuthController] logout error: $e');
    }
    state = const AuthState();
  }
}

String? validateCredentials(String email, String password) {
  if (email.trim().isEmpty || password.isEmpty) return 'emptyFields';
  if (!email.contains('@') || !email.contains('.')) return 'invalidEmail';
  if (password.length < 6) return 'shortPassword';
  return null;
}
