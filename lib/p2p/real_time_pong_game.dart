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
          final ball = world.children.query<Ball>().first;
          ball.velocity.setFrom(
            Vector2((data['bvx'] as num) * width, (data['bvy'] as num) * width),
          );
        }
        break;
      case 'paddle':
        findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.position.y =
            (data['y'] as num) * height;
        break;
      case 'score':
        leftPlayerScore = data['ls'] as int;
        rightPlayerScore = data['rs'] as int;
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
  void onDragUpdate(DragUpdateEvent event) {
    if (event.canvasStartPosition.x >= width / 2) {
      final paddle = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
      paddle?.moveBy(event.localDelta.y * 2);
      final y = paddle?.position.y ?? 0;
      manager.send(jsonEncode({'type': 'paddle', 'y': y / height}));
    }
  }

  @override
  void onTap() {
    if (isHost && gameState == GameState.welcome) {
      super.onTap();
      final ball = world.children.query<Ball>().first;
      manager.send(
        jsonEncode({
          'type': 'start',
          'bvx': ball.velocity.x / width,
          'bvy': ball.velocity.y / width,
        }),
      );
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      final paddle = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
      paddle?.moveBy(-paddleStep);
      final y = paddle?.position.y ?? 0;
      manager.send(jsonEncode({'type': 'paddle', 'y': y / height}));
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      final paddle = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
      paddle?.moveBy(paddleStep);
      final y = paddle?.position.y ?? 0;
      manager.send(jsonEncode({'type': 'paddle', 'y': y / height}));
    } else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      if (isHost) {
        startGame();
        final ball = world.children.query<Ball>().first;
        manager.send(
          jsonEncode({
            'type': 'start',
            'bvx': ball.velocity.x / width,
            'bvy': ball.velocity.y / width,
          }),
        );
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (allowPause && gameState == GameState.playing) {
        togglePause();
      }
    }
    return KeyEventResult.handled;
  }

  @override
  void leftPlayerPointWin() {
    super.leftPlayerPointWin();
    manager.send(
      jsonEncode({
        'type': 'score',
        'ls': leftPlayerScore,
        'rs': rightPlayerScore,
      }),
    );
  }

  @override
  void rightPlayerPointWin() {
    super.rightPlayerPointWin();
    manager.send(
      jsonEncode({
        'type': 'score',
        'ls': leftPlayerScore,
        'rs': rightPlayerScore,
      }),
    );
  }

  @override
  void onRemove() {
    manager.send(jsonEncode({'type': 'quit'}));
    super.onRemove();
  }
}
