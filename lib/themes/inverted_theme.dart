import 'package:easy_pong/themes/game_theme.dart';
import 'package:flutter/material.dart';

class InvertedTheme implements GameTheme {
  @override
  bool get isBallRound => false;

  @override
  Color get ballColor => Colors.black;

  @override
  Color get leftPaddleColor => Colors.black;

  @override
  Color get rightPaddleColor => Colors.black;

  @override
  Color get leftHudTextColor => Colors.black;

  @override
  Color get rightHudTextColor => Colors.black;

  @override
  Color get dividerColor => Colors.black;

  @override
  Color get backgroundColor => Colors.white;

  @override
  bool get isDividerContinuous => false;

  @override
  double get paddleBorderRadius => 0;

  @override
  String get hudFontFamily => "AtariClassic";

  @override
  String? get backgroundImageAssetPath => null;
}
