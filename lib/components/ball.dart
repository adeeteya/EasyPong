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
    required Vector2 velocity,
    super.size,
    super.position,
  })
      : velocity = Vector2.copy(velocity),
        _speed = velocity.length,
        super(anchor: Anchor.center);

  final bool isBallRound;
  final Color color;
  Vector2 velocity;
  double _speed;

  void _normalizeSpeed() {
    velocity
      ..normalize()
      ..scale(_speed);
  }

  void _increaseSpeed() {
    _speed *= 1.05;
    _normalizeSpeed();
  }

  @override
  void render(Canvas canvas) {
    if (isBallRound) {
      canvas.drawCircle(
        Offset(size.x / 2, size.x / 2),
        size.x / 2,
        color.filledPaint(),
      );
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
    _normalizeSpeed();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is ScreenHitbox) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
        game.playPing();
        _increaseSpeed();
      } else if (intersectionPoints.first.y >= game.height) {
        velocity.y = -velocity.y;
        game.playPing();
        _increaseSpeed();
      } else if (intersectionPoints.first.x <= 0) {
        add(
          RemoveEffect(
            delay: 1,
            onComplete: () {
              game.rightPlayerPointWin();
            },
          ),
        );
      } else if (intersectionPoints.first.x >= game.width - 0.2) {
        add(
          RemoveEffect(
            delay: 1,
            onComplete: () {
              game.leftPlayerPointWin();
            },
          ),
        );
      }
    } else if (other is Paddle) {
      velocity.x = -velocity.x;
      game.playPing();
      _increaseSpeed();
    }
  }
}
