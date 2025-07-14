import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/services/multiplayer_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Variant of [PongGame] that synchronizes state over the network using a
/// [MultiplayerService].
class MultiplayerPongGame extends PongGame {
  MultiplayerPongGame({
    required super.isMobile,
    required super.isSfxEnabled,
    required super.gameTheme,
    required this.service,
    required this.isLeftPlayer,
  }) : super(vsComputer: false);

  final MultiplayerService service;
  final bool isLeftPlayer;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    service.onData = _handleRemoteData;
    await service.connect();
  }

  @override
  void startGame() {
    super.startGame();
    final left = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
    final right = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
    if (isLeftPlayer) {
      right?.draggable = false;
    } else {
      left?.draggable = false;
    }
  }

  void _handleRemoteData(Map<String, dynamic> data) {
    final left = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
    final right = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
    final balls = world.children.query<Ball>();
    if (data['leftPaddleRatio'] != null && left != null) {
      left.position.y = (data['leftPaddleRatio'] as num).toDouble() * height;
    }
    if (data['rightPaddleRatio'] != null && right != null) {
      right.position.y = (data['rightPaddleRatio'] as num).toDouble() * height;
    }
    if (balls.isNotEmpty &&
        data['ballXRatio'] != null &&
        data['ballYRatio'] != null) {
      final ball = balls.first;
      ball.position.setValues(
        (data['ballXRatio'] as num).toDouble() * width,
        (data['ballYRatio'] as num).toDouble() * height,
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final left = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
    final right = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
    final balls = world.children.query<Ball>();
    final data = <String, dynamic>{
      'leftScore': leftPlayerScore,
      'rightScore': rightPlayerScore,
    };
    if (isLeftPlayer) {
      data['leftPaddleRatio'] =
          left?.position.y != null ? left!.position.y / height : null;
      if (balls.isNotEmpty) {
        data['ballXRatio'] = balls.first.position.x / width;
        data['ballYRatio'] = balls.first.position.y / height;
      }
    } else {
      data['rightPaddleRatio'] =
          right?.position.y != null ? right!.position.y / height : null;
    }
    service.send(data);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isLeftPlayer && event.canvasStartPosition.x < width / 2) {
      findByKey<Paddle>(
        ComponentKey.named('LeftPaddle'),
      )?.moveBy(event.localDelta.y * 2);
    } else if (!isLeftPlayer && event.canvasStartPosition.x > width / 2) {
      findByKey<Paddle>(
        ComponentKey.named('RightPaddle'),
      )?.moveBy(event.localDelta.y * 2);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    if (isLeftPlayer) {
      if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
        findByKey<Paddle>(
          ComponentKey.named('LeftPaddle'),
        )?.moveBy(-paddleStep);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
        findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(paddleStep);
      }
    } else {
      if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        findByKey<Paddle>(
          ComponentKey.named('RightPaddle'),
        )?.moveBy(-paddleStep);
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        findByKey<Paddle>(
          ComponentKey.named('RightPaddle'),
        )?.moveBy(paddleStep);
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      startGame();
    }
    return KeyEventResult.handled;
  }

  @override
  void onRemove() {
    service.close();
    super.onRemove();
  }
}
