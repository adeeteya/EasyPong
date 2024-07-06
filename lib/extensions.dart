import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Paint filledPaint() {
    return Paint()
      ..color = this
      ..style = PaintingStyle.fill;
  }
}
