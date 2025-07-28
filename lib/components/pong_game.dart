import 'dart:async';
import 'dart:math' as math;

import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/models/computer_difficulty.dart';
import 'package:easy_pong/overlays/score_hud.dart';
import 'package:easy_pong/screens/game_app.dart';
import 'package:easy_pong/themes/game_theme.dart';
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
  }) : super(children: [ScreenHitbox()]);

  final bool isMobile;
  late final double width;
  late final double height;
  final bool isSfxEnabled;
  final GameTheme gameTheme;
  final bool vsComputer;
  final ComputerDifficulty difficulty;
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
  }

  @override
  void onTap() {
    super.onTap();
    if (gameState == GameState.welcome) {
      startGame();
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!vsComputer && event.canvasStartPosition.x < width / 2) {
      // Move the left paddle only when playing local multiplayer
      findByKey<Paddle>(
        ComponentKey.named('LeftPaddle'),
      )?.moveBy(event.localDelta.y * 2);
    } else if (event.canvasStartPosition.x >= width / 2) {
      // Always allow the player to control the right paddle
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
    // Move the right paddle (player) using arrow keys
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.moveBy(-paddleStep);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.moveBy(paddleStep);
    }
    // Move the left paddle only in local multiplayer mode
    if (!vsComputer && keysPressed.contains(LogicalKeyboardKey.keyW)) {
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(-paddleStep);
    } else if (!vsComputer && keysPressed.contains(LogicalKeyboardKey.keyS)) {
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
            final diff = desiredY - aiPaddle.position.y;
            final step = diff.clamp(-height * 0.5 * dt, height * 0.5 * dt);
            aiPaddle.position.y = (aiPaddle.position.y + step).clamp(
              0,
              height - aiPaddle.size.y,
            );
            break;
          case ComputerDifficulty.easy:
            final diff = desiredY - aiPaddle.position.y;
            final step = diff.clamp(-height * 0.3 * dt, height * 0.3 * dt);
            aiPaddle.position.y = (aiPaddle.position.y + step).clamp(
              0,
              height - aiPaddle.size.y,
            );
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

  void togglePause() {
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
