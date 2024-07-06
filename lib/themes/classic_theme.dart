import 'package:easy_pong/themes/game_theme.dart';
import 'package:flutter/material.dart';

class ClassicTheme implements GameTheme {
  @override
  bool get isBallRound => false;

  @override
  Color get ballColor => Colors.white;

  @override
  Color get leftPaddleColor => Colors.white;

  @override
  Color get rightPaddleColor => Colors.white;

  @override
  Color get leftHudTextColor => Colors.white;

  @override
  Color get rightHudTextColor => Colors.white;

  @override
  Color get dividerColor => Colors.white;

  @override
  Color get backgroundColor => Colors.black;

  @override
  bool get isDividerContinuous => false;

  @override
  double get paddleBorderRadius => 0;

  @override
  String get hudFontFamily => "AtariClassic";

  @override
  String? get backgroundImageAssetPath => null;
}
