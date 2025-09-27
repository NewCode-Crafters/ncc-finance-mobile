import 'package:flutter/material.dart';

enum AppMessageType { success, error, info, warning }

SnackBar buildAppSnackBar(String message, AppMessageType type) {
  final iconColor = Colors.white;
  late final Color background;
  late final IconData icon;

  switch (type) {
    case AppMessageType.success:
      background = Colors.green[600]!;
      icon = Icons.check_circle;
      break;
    case AppMessageType.error:
      background = Colors.red[700]!;
      icon = Icons.error;
      break;
    case AppMessageType.warning:
      background = Colors.orange[800]!;
      icon = Icons.warning;
      break;
    case AppMessageType.info:
      background = Colors.blue[600]!;
      icon = Icons.info;
      break;
  }

  return SnackBar(
    content: Row(
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
    backgroundColor: background,
  );
}

/// shows the snackbar immediately.
void showAppSnackBar(
  BuildContext context,
  String message,
  AppMessageType type,
) {
  ScaffoldMessenger.of(context).showSnackBar(buildAppSnackBar(message, type));
}
