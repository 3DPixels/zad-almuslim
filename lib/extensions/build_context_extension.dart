import 'package:flutter/material.dart';

extension ResponsiveScaleExtension on BuildContext {
  /// Scales a base size (like an icon size or container height)
  /// proportionally with the OS text size setting, clamped to a safe range.
  double scaleSize(double baseSize, {double maxScale = 1.4}) {
    final textScaler = MediaQuery.textScalerOf(
      this,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: maxScale);
    return textScaler.scale(baseSize);
  }

  /// Current effective text scale factor (1.0 is default)
  double get textScaleFactor =>
      MediaQuery.textScalerOf(this).scale(10.0) / 10.0;
}
