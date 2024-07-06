import 'package:easy_pong/themes/game_theme.dart';
import 'package:flutter/material.dart';

class ModernTheme implements GameTheme {
  @override
  bool get isBallRound => true;

  @override
  Color get ballColor => Colors.white;

  @override
  Color get leftPaddleColor => const Color(0xFF9c6221);

  @override
  Color get rightPaddleColor => const Color(0xFF4e8678);

  @override
  Color get leftHudTextColor => const Color(0xFF9c6221);

  @override
  Color get rightHudTextColor => const Color(0xFF4e8678);

  @override
  Color get dividerColor => const Color(0xFF242424);

  @override
  Color get backgroundColor => const Color(0xFF333333);

  @override
  bool get isDividerContinuous => true;

  @override
  double get paddleBorderRadius => 20;

  @override
  String get hudFontFamily => "Roboto";

  @override
  String? get backgroundImageAssetPath => null;
}
