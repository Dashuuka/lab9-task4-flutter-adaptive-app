import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Hive.init('lab9_hive');
    await Hive.openBox<dynamic>('lab9_cache');
  } catch (e) {
    debugPrint('[Main] cache init error: $e');
  }
  runApp(const ProviderScope(child: Lab9AdaptiveApp()));
}
