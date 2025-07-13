import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/extensions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Paddle extends PositionComponent
    with DragCallbacks, HasGameReference<PongGame> {
  Paddle(
      {required this.paddleBorderRadius,
      required this.paddleColor,
      super.key,
      super.position,
      super.size})
      : super(
          children: [RectangleHitbox()],
        );

  final double paddleBorderRadius;
  final Color paddleColor;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        Radius.circular(paddleBorderRadius),
      ),
      paddleColor.filledPaint(),
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.y =
        (position.y + event.localDelta.y).clamp(0, game.height - size.y);
  }

  void moveBy(double dy) {
    add(MoveToEffect(
      Vector2(position.x, (position.y + dy).clamp(0, game.height - size.y)),
      EffectController(duration: 0.1),
    ));
  }
}
