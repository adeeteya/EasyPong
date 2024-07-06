import 'package:easy_pong/themes/inverted_theme.dart';
import 'package:flutter/material.dart';

class YellowBgTheme extends InvertedTheme {
  @override
  bool get isBallRound => true;

  @override
  Color get backgroundColor => const Color(0xFFFFFF54);
}
