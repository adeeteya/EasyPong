import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/extensions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class Paddle extends PositionComponent
    with DragCallbacks, HasGameReference<PongGame> {
  Paddle({
    required this.paddleBorderRadius,
    required this.paddleColor,
    super.key,
    super.position,
    super.size,
  }) : super(children: [RectangleHitbox()]);

  final double paddleBorderRadius;
  final Color paddleColor;

  double _previousY = 0;
  double _velocityY = 0;

  double get verticalVelocity => _velocityY;

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
  Future<void> onLoad() async {
    await super.onLoad();
    _previousY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _velocityY = (position.y - _previousY) / dt;
    _previousY = position.y;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.y = (position.y + event.localDelta.y).clamp(
      0,
      game.height - size.y,
    );
  }

  void moveBy(double dy) {
    add(
      MoveToEffect(
        Vector2(position.x, (position.y + dy).clamp(0, game.height - size.y)),
        EffectController(duration: 0.1),
      ),
    );
  }
}
