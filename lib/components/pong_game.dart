import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';

import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/models/computer_difficulty.dart';
import 'package:easy_pong/overlays/score_hud.dart';
import 'package:easy_pong/screens/game_app.dart';
import 'package:easy_pong/themes/game_theme.dart';
import 'package:easy_pong/network/lan_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:easy_pong/screens/game_app.dart';

class PongGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector, DragCallbacks {
  PongGame({
    required this.isMobile,
    required this.isSfxEnabled,
    required this.gameTheme,
    this.vsComputer = false,
    this.difficulty = ComputerDifficulty.impossible,
    this.lanService,
    this.isHost = false,
  }) : super(children: [ScreenHitbox()]);

  final bool isMobile;
  late final double width;
  late final double height;
  final bool isSfxEnabled;
  final GameTheme gameTheme;
  final bool vsComputer;
  final ComputerDifficulty difficulty;
  final LanService? lanService;
  final bool isHost;
  bool get isLan => lanService != null;
  int leftPlayerScore = 0;
  int rightPlayerScore = 0;
  late final Vector2 paddleSize;
  late final double paddleStep;
  final rand = math.Random();
  double horizontalSafeArea = 0;

  bool _isPaused = false;

  late GameState _gameState;
  GameState get gameState => _gameState;
  set gameState(GameState gameState) {
    _gameState = gameState;
    switch (gameState) {
      case GameState.welcome:
      case GameState.gameOver:
        camera.viewport.removeAll(camera.viewport.children.query<ScoreHud>());
        world.removeAll(world.children.query<Paddle>());
        overlays.add(gameState.name);
        overlays.remove(GameState.paused.name);
        _isPaused = false;
        break;
      case GameState.playing:
        overlays.remove(GameState.welcome.name);
        overlays.remove(GameState.gameOver.name);
        overlays.remove(GameState.paused.name);
        break;
      case GameState.paused:
        overlays.add(GameState.paused.name);
        overlays.remove(GameState.welcome.name);
        overlays.remove(GameState.gameOver.name);
        break;
    }
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    if (isMobile) {
      width = size[1];
      height = size[0];
    } else {
      width = size[0];
      height = size[1];
    }
    super.camera = CameraComponent.withFixedResolution(
      width: width,
      height: height,
    );
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.backdrop =
        (gameTheme.backgroundImageAssetPath != null)
            ? ImageAssetBackground(gameTheme.backgroundImageAssetPath!)
            : CenterLineDivider(
              isDividerContinuous: gameTheme.isDividerContinuous,
              dividerColor: gameTheme.dividerColor,
            );
    paddleSize = Vector2(width * 0.02, height * 0.2);
    paddleStep = height * 0.05;
    gameState = GameState.welcome;
    if (isLan) {
      lanService!.messages.listen(_handleMessage);
    }
  }

  @override
  Color backgroundColor() {
    return gameTheme.backgroundColor;
  }

  void startGame() {
    //if game is already being played then return
    if (gameState == GameState.playing) return;

    //remove existing elements if game is being played again
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Paddle>());

    //set game to playing state
    gameState = GameState.playing;

    //initialize both player scores to zero
    leftPlayerScore = 0;
    rightPlayerScore = 0;

    //add score HUD on top
    camera.viewport.add(
      ScoreHud(
        leftHudTextColor: gameTheme.leftHudTextColor,
        rightHudTextColor: gameTheme.rightHudTextColor,
        fontFamily: gameTheme.hudFontFamily,
      ),
    );

    //add the left player paddle
    world.add(
      Paddle(
        key: ComponentKey.named('LeftPaddle'),
        paddleBorderRadius: gameTheme.paddleBorderRadius,
        paddleColor: gameTheme.leftPaddleColor,
        position: Vector2(horizontalSafeArea, height / 2),
        size: paddleSize,
        isDragCallbackEnabled: !vsComputer,
      ),
    );

    //add the right player paddle
    world.add(
      Paddle(
        key: ComponentKey.named('RightPaddle'),
        paddleBorderRadius: gameTheme.paddleBorderRadius,
        paddleColor: gameTheme.rightPaddleColor,
        position: Vector2(
          width - paddleSize.x - horizontalSafeArea,
          height / 2,
        ),
        size: paddleSize,
      ),
    );

    //add the ball to be used in the game
    addBallToTheWorld();
    if (isLan && isHost) {
      lanService?.send({'type': 'start'});
    }
  }

  @override
  void onTap() {
    super.onTap();
    if (gameState == GameState.welcome) {
      if (!isLan || isHost) {
        startGame();
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isLan) {
      if (event.canvasStartPosition.x >= width / 2) {
        final paddle =
            findByKey<Paddle>(ComponentKey.named('RightPaddle'));
        paddle?.moveBy(event.localDelta.y * 2);
        if (!isHost) {
          lanService?.send({'type': 'input', 'y': paddle?.position.y});
        }
      }
    } else {
      if (!vsComputer && event.canvasStartPosition.x < width / 2) {
        findByKey<Paddle>(
          ComponentKey.named('LeftPaddle'),
        )?.moveBy(event.localDelta.y * 2);
      } else if (event.canvasStartPosition.x >= width / 2) {
        findByKey<Paddle>(
          ComponentKey.named('RightPaddle'),
        )?.moveBy(event.localDelta.y * 2);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    // Move the right paddle (player) using arrow keys
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      final paddle =
          findByKey<Paddle>(ComponentKey.named('RightPaddle'));
      paddle?.moveBy(-paddleStep);
      if (isLan && !isHost) {
        lanService?.send({'type': 'input', 'y': paddle?.position.y});
      }
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      final paddle =
          findByKey<Paddle>(ComponentKey.named('RightPaddle'));
      paddle?.moveBy(paddleStep);
      if (isLan && !isHost) {
        lanService?.send({'type': 'input', 'y': paddle?.position.y});
      }
    }
    // Move the left paddle only in local multiplayer mode
    if (!vsComputer && !isLan && keysPressed.contains(LogicalKeyboardKey.keyW)) {
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(-paddleStep);
    } else if (!vsComputer && !isLan && keysPressed.contains(LogicalKeyboardKey.keyS)) {
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(paddleStep);
    }
    //To start the game in devices connected to the keyboard
    else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      startGame();
    } else if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (gameState == GameState.playing) {
        togglePause();
      }
    }
    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isLan && isHost && gameState == GameState.playing) {
      _sendState();
    }
    if (vsComputer && gameState == GameState.playing) {
      // Computer controls the left paddle in vs computer mode
      final aiPaddle = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
      final balls = world.children.query<Ball>();
      if (aiPaddle != null && balls.isNotEmpty) {
        final ball = balls.first;
        final desiredY = ball.position.y - aiPaddle.size.y / 2;
        switch (difficulty) {
          case ComputerDifficulty.impossible:
            aiPaddle.position.y = desiredY.clamp(0, height - aiPaddle.size.y);
            break;
          case ComputerDifficulty.medium:
            aiPaddle.position.y = (aiPaddle.position.y +
                    (desiredY - aiPaddle.position.y) * 0.1)
                .clamp(0, height - aiPaddle.size.y);
            break;
          case ComputerDifficulty.easy:
            aiPaddle.position.y = (aiPaddle.position.y +
                    (desiredY - aiPaddle.position.y) * 0.05)
                .clamp(0, height - aiPaddle.size.y);
            break;
        }
      }
    }
  }

  void playPing() {
    if (isSfxEnabled) {
      FlameAudio.play('ping.mp3');
    }
  }

  void addBallToTheWorld({bool? startsWithRightPlayer}) {
    world.add(
      Ball(
        color: gameTheme.ballColor,
        isBallRound: gameTheme.isBallRound,
        velocity: randomBallVelocity(
          startsWithRightPlayer: startsWithRightPlayer,
        ),
        size: Vector2(width * 0.02, width * 0.02),
        position: Vector2(width / 2, height / 2),
      ),
    );
  }

  Vector2 randomBallVelocity({bool? startsWithRightPlayer}) {
    if (startsWithRightPlayer == null) {
      return Vector2(
          (rand.nextDouble() - 0.5) * width,
          (rand.nextDouble() * 0.4 - 0.2) * height,
        ).normalized()
        ..scale(width / 1.5);
    } else if (startsWithRightPlayer) {
      return Vector2(
          (rand.nextDouble() * 0.35 + 0.15) * width,
          (rand.nextDouble() * 0.4 - 0.2) * height,
        ).normalized()
        ..scale(width / 1.5);
    } else {
      return Vector2(
          (rand.nextDouble() * 0.35 - 0.5) * width,
          (rand.nextDouble() * 0.4 - 0.2) * height,
        ).normalized()
        ..scale(width / 1.5);
    }
  }

  void leftPlayerPointWin() {
    leftPlayerScore++;
    if (leftPlayerScore == 10) {
      gameState = GameState.gameOver;
      return;
    }
    addBallToTheWorld(startsWithRightPlayer: false);
  }

  void rightPlayerPointWin() {
    rightPlayerScore++;
    if (rightPlayerScore == 10) {
      gameState = GameState.gameOver;
      return;
    }
    addBallToTheWorld(startsWithRightPlayer: true);
  }

  void _handleMessage(String msg) {
    try {
      final data = jsonDecode(msg);
      final type = data['type'];
      if (type == 'input' && isHost) {
        final paddle = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
        if (paddle != null && data['y'] != null) {
          paddle.position.y = (data['y'] as num).toDouble();
        }
      } else if (type == 'state' && !isHost) {
        _applyStateFromHost(data);
      } else if (type == 'quit' || type == 'disconnect') {
        rightPlayerScore = 10;
        leftPlayerScore = 0;
        gameState = GameState.gameOver;
      }
    } catch (_) {}
  }

  void _applyStateFromHost(Map<String, dynamic> data) {
    final leftP = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
    final rightP = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
    leftP?.position.y = (data['hostY'] as num).toDouble();
    if (data['clientY'] != null) {
      rightP?.position.y = (data['clientY'] as num).toDouble();
    }
    final balls = world.children.query<Ball>();
    final ball = balls.isNotEmpty ? balls.first : null;
    if (ball != null) {
      final bx = (data['ballX'] as num).toDouble();
      final by = (data['ballY'] as num).toDouble();
      final vx = (data['ballVx'] as num).toDouble();
      final vy = (data['ballVy'] as num).toDouble();
      ball.position = Vector2(width - bx, by);
      ball.velocity.setValues(-vx, vy);
    }
    leftPlayerScore = (data['hostScore'] as num).toInt();
    rightPlayerScore = (data['clientScore'] as num).toInt();
    final stateName = data['state'] as String;
    gameState = GameState.values.byName(stateName);
  }

  void _sendState() {
    final ballsSend = world.children.query<Ball>();
    final ball = ballsSend.isNotEmpty ? ballsSend.first : null;
    final leftP = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
    final rightP = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
    if (ball == null || leftP == null || rightP == null) return;
    lanService?.send({
      'type': 'state',
      'ballX': ball.position.x,
      'ballY': ball.position.y,
      'ballVx': ball.velocity.x,
      'ballVy': ball.velocity.y,
      'hostY': rightP.position.y,
      'clientY': leftP.position.y,
      'hostScore': rightPlayerScore,
      'clientScore': leftPlayerScore,
      'state': gameState.name,
    });
  }

  void togglePause() {
    if (isLan) return;
    if (_isPaused) {
      resumeEngine();
      gameState = GameState.playing;
    } else {
      pauseEngine();
      gameState = GameState.paused;
    }
    _isPaused = !_isPaused;
  }
}
