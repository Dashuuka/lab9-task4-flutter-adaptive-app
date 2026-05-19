import 'package:flutter/material.dart';

class NotificationService {
  void show(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> prepareMobileStub() async {
    debugPrint(
      '[Notifications] local notification service placeholder is ready',
    );
  }
}
