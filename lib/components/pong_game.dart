import 'dart:async';
import 'package:easy_pong/overlays/score_hud.dart';
import 'package:easy_pong/themes/game_theme.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:easy_pong/screens/game_app.dart';
import 'package:easy_pong/components/components.dart';
export 'package:easy_pong/screens/game_app.dart';

class PongGame extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector, DragCallbacks {
  PongGame(
      {required this.width,
      required this.height,
      required this.isSfxEnabled,
      required this.gameTheme})
      : super(
          children: [ScreenHitbox()],
          camera:
              CameraComponent.withFixedResolution(width: width, height: height),
        );

  final double width;
  final double height;
  final bool isSfxEnabled;
  final GameTheme gameTheme;
  int leftPlayerScore = 0;
  int rightPlayerScore = 0;
  late final Vector2 paddleSize;
  late final double paddleStep;
  final rand = math.Random();

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
        break;
      case GameState.playing:
        overlays.remove(GameState.welcome.name);
        overlays.remove(GameState.gameOver.name);
    }
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.backdrop = (gameTheme.backgroundImageAssetPath != null)
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
        position: Vector2(20, height / 2),
        size: paddleSize,
      ),
    );

    //add the right player paddle
    world.add(
      Paddle(
        key: ComponentKey.named('RightPaddle'),
        paddleBorderRadius: gameTheme.paddleBorderRadius,
        paddleColor: gameTheme.rightPaddleColor,
        position: Vector2(width - paddleSize.x - 20, height / 2),
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
    if (event.canvasStartPosition.x < width / 2) {
      //To Move the Left Paddle By Drag
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))
          ?.moveBy(event.localDelta.y * 2);
    } else {
      //To Move the Right Paddle By Drag
      findByKey<Paddle>(ComponentKey.named('RightPaddle'))
          ?.moveBy(event.localDelta.y * 2);
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    //To Move the Right Paddle
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.moveBy(-paddleStep);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      findByKey<Paddle>(ComponentKey.named('RightPaddle'))?.moveBy(paddleStep);
    }
    //To Move the Left Paddle
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(-paddleStep);
    } else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      findByKey<Paddle>(ComponentKey.named('LeftPaddle'))?.moveBy(paddleStep);
    }
    //To start the game in devices connected to the keyboard
    else if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space) {
      startGame();
    }
    return KeyEventResult.handled;
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
        velocity:
            randomBallVelocity(startsWithRightPlayer: startsWithRightPlayer),
        size: Vector2(width * 0.02, width * 0.02),
        position: Vector2(width / 2, height / 2),
      ),
    );
  }

  Vector2 randomBallVelocity({bool? startsWithRightPlayer}) {
    if (startsWithRightPlayer == null) {
      return Vector2((rand.nextDouble() - 0.5) * width,
              (rand.nextDouble() * 0.4 - 0.2) * height)
          .normalized()
        ..scale(width / 1.5);
    } else if (startsWithRightPlayer) {
      return Vector2((rand.nextDouble() * 0.35 + 0.15) * width,
              (rand.nextDouble() * 0.4 - 0.2) * height)
          .normalized()
        ..scale(width / 1.5);
    } else {
      return Vector2((rand.nextDouble() * 0.35 - 0.5) * width,
              (rand.nextDouble() * 0.4 - 0.2) * height)
          .normalized()
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
}
