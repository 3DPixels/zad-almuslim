import 'package:flutter/material.dart';

class CardPalette {
  final Color iconColor;
  final Color glowColor; // The icon container background
  final Color gradientColor; // The radial gradient start

  const CardPalette({
    required this.iconColor,
    required this.glowColor,
    required this.gradientColor,
  });
}
