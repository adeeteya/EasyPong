import 'dart:async';
import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/extensions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CenterLineDivider extends PositionComponent
    with HasGameReference<PongGame> {
  CenterLineDivider(
      {required this.dividerColor, required this.isDividerContinuous})
      : super();
  final Color dividerColor;
  final bool isDividerContinuous;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    if (isDividerContinuous) {
      await add(RectangleComponent(
        position: Vector2(game.width / 2, 0),
        size: Vector2(5, game.height),
        paint: dividerColor.filledPaint(),
      ));
    } else {
      await addAll(
        List.generate(
          30,
          (index) => RectangleComponent(
            position: Vector2(
                game.width / 2, (game.height / 30) * index + (index * 10)),
            size: Vector2(5, game.height / 30),
            paint: dividerColor.filledPaint(),
          ),
        ),
      );
    }
  }
}
