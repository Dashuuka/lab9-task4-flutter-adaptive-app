import 'dart:io';

import 'package:hive/hive.dart';

Future<void> initHiveStorage() async {
  final dir = Directory(
    '${Directory.systemTemp.path}${Platform.pathSeparator}task4_flutter_adaptive_app_hive',
  );
  await dir.create(recursive: true);
  Hive.init(dir.path);
}
