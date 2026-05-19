import 'package:flutter/widgets.dart';

class Responsive {
  static bool compact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 720;
  static int columns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1200) return 3;
    if (width >= 720) return 2;
    return 1;
  }
}
