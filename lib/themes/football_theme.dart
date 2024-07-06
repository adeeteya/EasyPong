import 'package:easy_pong/themes/classic_theme.dart';
import 'package:flutter/material.dart';

class FootballTheme extends ClassicTheme {
  @override
  bool get isBallRound => true;

  @override
  Color get ballColor => const Color(0xFFFFD18D);

  @override
  Color get leftPaddleColor => const Color(0xFFE59B59);

  @override
  Color get rightPaddleColor => const Color(0xFFA96728);

  @override
  Color get leftHudTextColor => const Color(0xFFE59B59);

  @override
  Color get rightHudTextColor => const Color(0xFFA96728);

  @override
  double get paddleBorderRadius => 4;

  @override
  String? get backgroundImageAssetPath => "pixel_football_field.jpg";
}
