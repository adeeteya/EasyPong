import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_pong/components/pong_game.dart';
import 'package:flame/components.dart';

class ScoreHud extends PositionComponent with HasGameReference<PongGame> {
  ScoreHud({
    required this.leftHudTextColor,
    required this.rightHudTextColor,
    required this.fontFamily,
  }) : super();
  final Color leftHudTextColor;
  final Color rightHudTextColor;
  final String fontFamily;
  late final TextComponent _leftPlayerTextComponent;
  late final TextComponent _rightPlayerTextComponent;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _leftPlayerTextComponent = TextComponent(
      text: "0",
      position: Vector2(game.width * 0.3, 10),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: leftHudTextColor,
        ),
      ),
    );
    _rightPlayerTextComponent = TextComponent(
      text: "0",
      position: Vector2(game.width * 0.7, 10),
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: rightHudTextColor,
        ),
      ),
    );
    add(_leftPlayerTextComponent);
    add(_rightPlayerTextComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _leftPlayerTextComponent.text = "${game.leftPlayerScore}";
    _rightPlayerTextComponent.text = "${game.rightPlayerScore}";
  }
}
