import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'app/app.dart';
import 'core/storage/hive_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initHiveStorage();
    await Hive.openBox<dynamic>('lab9_cache');
  } catch (e) {
    debugPrint('[Main] cache init error: $e');
  }
  runApp(const ProviderScope(child: Lab9AdaptiveApp()));
}
