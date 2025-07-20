import 'dart:convert';

import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/p2p/p2p_manager.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RealTimePongGame extends PongGame {
  final P2pManager manager;
  final bool isHost;

  RealTimePongGame({
    required this.manager,
    required this.isHost,
    required super.isMobile,
    required super.isSfxEnabled,
    required super.gameTheme,
  }) : super(allowPause: false);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    manager.messages.listen(_handleMessage);
    if (!isHost) {
      // Disable local ball collisions on the client.
      final ball = world.children.query<Ball>().first;
      for (final hitbox in ball.children.whereType<ShapeHitbox>()) {
        hitbox.collisionType = CollisionType.inactive;
      }
    }
  }

  void _handleMessage(String message) {
    final data = jsonDecode(message) as Map<String, dynamic>;
    switch (data['type']) {
      case 'start':
        if (!isHost && gameState == GameState.welcome) {
          startGame();
        }
        break;
      case 'state':
        if (!isHost) {
          final ball = world.children.query<Ball>().first;
          ball.position = Vector2(
            (data['bx'] as num) * width,
            (data['by'] as num) * height,
          );
          ball.velocity.setFrom(
            Vector2((data['bvx'] as num) * width, (data['bvy'] as num) * width),
          );
          findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.position.y =
              (data['hostpaddley'] as num) * height;
          findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.position.y =
              (data['clientpaddley'] as num) * height;
          leftPlayerScore = data['ls'];
          rightPlayerScore = data['rs'];
        }
        break;
      case 'paddle':
        if (isHost) {
          findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.position.y =
              (data['clientpaddley'] as num) * height;
        }
        break;
      case 'quit':
        gameState = GameState.gameOver;
        if (isHost) {
          rightPlayerScore = 10;
        } else {
          leftPlayerScore = 10;
        }
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isHost && gameState == GameState.playing) {
      final ball = world.children.query<Ball>().first;
      manager.send(
        jsonEncode({
          'type': 'state',
          'bx': ball.position.x / width,
          'by': ball.position.y / height,
          'bvx': ball.velocity.x / width,
          'bvy': ball.velocity.y / width,
          'hostpaddley':
              (findByKey<Paddle>(
                    ComponentKey.named('RightPaddle'),
                  )?.position.y ??
                  0) /
              height,
          'clientpaddley':
              (findByKey<Paddle>(
                    ComponentKey.named('LeftPaddle'),
                  )?.position.y ??
                  0) /
              height,
          'ls': leftPlayerScore,
          'rs': rightPlayerScore,
        }),
      );
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isHost) {
      if (event.canvasStartPosition.x >= width / 2) {
        findByKey<Paddle>(
          ComponentKey.named('RightPaddle'),
        )?.moveBy(event.localDelta.y * 2);
      }
    } else {
      if (event.canvasStartPosition.x >= width / 2) {
        final paddle = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
        paddle?.moveBy(event.localDelta.y * 2);
        final clientPaddleY = paddle?.position.y ?? 0;
        manager.send(
          jsonEncode({
            'type': 'paddle',
            'clientpaddley': clientPaddleY / height,
          }),
        );
      }
    }
  }

  @override
  void onTap() {
    if (isHost && gameState == GameState.welcome) {
      super.onTap();
      manager.send(jsonEncode({'type': 'start'}));
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (isHost) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        findByKey<Paddle>(
          ComponentKey.named('RightPaddle'),
        )?.moveBy(-paddleStep);
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        findByKey<Paddle>(
          ComponentKey.named('RightPaddle'),
        )?.moveBy(paddleStep);
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        startGame();
        manager.send(jsonEncode({'type': 'start'}));
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        if (allowPause && gameState == GameState.playing) {
          togglePause();
        }
      }
    } else {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        final paddle = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
        paddle?.moveBy(-paddleStep);
        final clientPaddleY = paddle?.position.y ?? 0;
        manager.send(
          jsonEncode({
            'type': 'paddle',
            'clientpaddley': clientPaddleY / height,
          }),
        );
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        final paddle = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
        paddle?.moveBy(paddleStep);
        final clientPaddleY = paddle?.position.y ?? 0;
        manager.send(
          jsonEncode({
            'type': 'paddle',
            'clientpaddley': clientPaddleY / height,
          }),
        );
      }
    }
    return KeyEventResult.handled;
  }

  @override
  void onRemove() {
    manager.send(jsonEncode({'type': 'quit'}));
    super.onRemove();
  }
}
