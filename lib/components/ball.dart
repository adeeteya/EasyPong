import 'dart:async';
import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/extensions.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class Ball extends PositionComponent
    with CollisionCallbacks, HasGameReference<PongGame> {
  Ball({
    required this.color,
    required this.isBallRound,
    required this.velocity,
    super.size,
    super.position,
  }) : super(anchor: Anchor.center);

  final bool isBallRound;
  final Color color;
  final Vector2 velocity;

  @override
  void render(Canvas canvas) {
    if (isBallRound) {
      canvas.drawCircle(
          Offset(size.x / 2, size.x / 2), size.x / 2, color.filledPaint());
    } else {
      canvas.drawRect(Offset.zero & size.toSize(), color.filledPaint());
    }
  }

  @override
  FutureOr<void> onLoad() {
    if (isBallRound) {
      add(CircleHitbox());
    } else {
      add(RectangleHitbox());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ScreenHitbox) {
      final speed = velocity.length;
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
        velocity.setFrom(velocity.normalized()..scale(speed));
        game.playPing();
      } else if (intersectionPoints.first.y >= game.height) {
        velocity.y = -velocity.y;
        velocity.setFrom(velocity.normalized()..scale(speed));
        game.playPing();
      } else if (intersectionPoints.first.x <= 0) {
        add(RemoveEffect(
            delay: 1,
            onComplete: () {
              game.rightPlayerPointWin();
            }));
      } else if (intersectionPoints.first.x >= game.width - 0.2) {
        add(RemoveEffect(
            delay: 1,
            onComplete: () {
              game.leftPlayerPointWin();
            }));
      }
    } else if (other is Paddle) {
      final speed = velocity.length;
      velocity.x = -velocity.x;
      final impact =
          ((position.y - other.position.y) / other.size.y).clamp(-0.5, 0.5);
      velocity.y = velocity.y + impact * game.height * 0.3 +
          other.verticalVelocity * 0.05;
      velocity.setFrom(velocity.normalized()..scale(speed));
      game.playPing();
    }
  }
}
