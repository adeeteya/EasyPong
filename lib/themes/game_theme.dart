import 'package:flutter/material.dart';

abstract class GameTheme {
  final bool isBallRound;
  final Color ballColor;
  final Color leftPaddleColor;
  final Color rightPaddleColor;
  final Color leftHudTextColor;
  final Color rightHudTextColor;
  final Color dividerColor;
  final Color backgroundColor;
  final bool isDividerContinuous;
  final double paddleBorderRadius;
  final String hudFontFamily;
  final String? backgroundImageAssetPath;

  GameTheme({
    required this.isBallRound,
    required this.ballColor,
    required this.leftPaddleColor,
    required this.rightPaddleColor,
    required this.leftHudTextColor,
    required this.rightHudTextColor,
    required this.dividerColor,
    required this.backgroundColor,
    required this.isDividerContinuous,
    required this.paddleBorderRadius,
    required this.hudFontFamily,
    this.backgroundImageAssetPath,
  });
}
