import 'dart:convert';

import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/p2p/p2p_manager.dart';
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
              (data['ly'] as num) * height;
          findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.position.y =
              (data['ry'] as num) * height;
          leftPlayerScore = data['ls'];
          rightPlayerScore = data['rs'];
        }
        break;
      case 'paddle':
        if (isHost) {
          findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.position.y =
              (data['ry'] as num) * height;
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
          'ly':
              (findByKey<Paddle>(
                    ComponentKey.named('LeftPaddle'),
                  )?.position.y ??
                  0) /
              height,
          'ry':
              (findByKey<Paddle>(
                    ComponentKey.named('RightPaddle'),
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
    super.onDragUpdate(event);
    if (!isHost && event.canvasStartPosition.x >= width / 2) {
      final ry =
          findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.position.y ?? 0;
      manager.send(jsonEncode({'type': 'paddle', 'ry': ry / height}));
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
    super.onKeyEvent(event, keysPressed);
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.moveBy(-paddleStep);
      if (!isHost) {
        final ry =
            findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.position.y ??
            0;
        manager.send(jsonEncode({'type': 'paddle', 'ry': ry / height}));
      }
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.moveBy(paddleStep);
      if (!isHost) {
        final ry =
            findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.position.y ??
            0;
        manager.send(jsonEncode({'type': 'paddle', 'ry': ry / height}));
      }
    }
    if (!vsComputer && keysPressed.contains(LogicalKeyboardKey.keyW)) {
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(-paddleStep);
    } else if (!vsComputer && keysPressed.contains(LogicalKeyboardKey.keyS)) {
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(paddleStep);
    } else if (isHost &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      startGame();
      manager.send(jsonEncode({'type': 'start'}));
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (allowPause && gameState == GameState.playing) {
        togglePause();
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
