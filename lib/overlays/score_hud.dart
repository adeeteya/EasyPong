import 'dart:async';

import 'package:easy_pong/components/pong_game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

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
  late final HudButtonComponent _pauseButton;

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
    _pauseButton = HudButtonComponent(
      anchor: Anchor.topCenter,
      position: Vector2(game.width / 2, 10),
      size: Vector2.all(40),
      button: _buildPauseButton(game.gameTheme.ballColor,
          game.gameTheme.backgroundColor),
      onPressed: game.togglePause,
    );
    addAll([
      _leftPlayerTextComponent,
      _rightPlayerTextComponent,
      _pauseButton,
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _leftPlayerTextComponent.text = "${game.leftPlayerScore}";
    _rightPlayerTextComponent.text = "${game.rightPlayerScore}";
  }

  PositionComponent _buildPauseButton(Color background, Color iconColor) {
    return PositionComponent(
      size: Vector2.all(40),
      children: [
        CircleComponent(
          radius: 20,
          anchor: Anchor.center,
          position: Vector2.all(20),
          paint: Paint()..color = background,
        ),
        TextComponent(
          text: String.fromCharCode(Icons.pause.codePoint),
          anchor: Anchor.center,
          position: Vector2.all(20),
          textRenderer: TextPaint(
            style: TextStyle(
              fontFamily: Icons.pause.fontFamily,
              color: iconColor,
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }
}
