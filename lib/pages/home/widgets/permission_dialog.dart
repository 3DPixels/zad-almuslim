import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String content;
  final bool isPermanent;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.content,
    this.isPermanent = false,
  });

  /// Static helper to easily trigger the dialog from anywhere
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    bool isPermanent = false,
  }) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => PermissionDialog(
        title: title,
        content: content,
        isPermanent: isPermanent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        if (isPermanent)
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('الإعدادات'),
          ),
      ],
    );
  }
}
