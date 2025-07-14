import 'dart:async';
import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/online/firebase_game_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:firebase_database/firebase_database.dart';

class OnlinePongGame extends PongGame {
  OnlinePongGame({
    required super.isMobile,
    required super.isSfxEnabled,
    required super.gameTheme,
    required this.service,
    required this.isHost,
  }) : super(vsComputer: false);

  final FirebaseGameService service;
  final bool isHost;
  StreamSubscription? _sub;

  ComponentKey get localKey =>
      isHost ? ComponentKey.named('RightPaddle') : ComponentKey.named('LeftPaddle');
  ComponentKey get remoteKey =>
      isHost ? ComponentKey.named('LeftPaddle') : ComponentKey.named('RightPaddle');

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _sub = service.gameStream().listen(_onData);
  }

  void _onData(DatabaseEvent event) {
    final data = (event.snapshot.value ?? {}) as Map;
    final paddles = data['paddles'] as Map?;
    if (paddles != null) {
      final remoteY = paddles[isHost ? 'left' : 'right'];
      if (remoteY is num) {
        findByKey<Paddle>(remoteKey)?.position.y = remoteY.toDouble();
      }
    }
    if (!isHost) {
      final ball = data['ball'] as Map?;
      if (ball != null) {
        final b = world.children.query<Ball>().firstOrNull;
        if (b != null) {
          b.position = Vector2(
            (ball['x'] as num).toDouble(),
            (ball['y'] as num).toDouble(),
          );
        }
      }
      final score = data['score'] as Map?;
      if (score != null) {
        leftPlayerScore = (score['left'] as num).toInt();
        rightPlayerScore = (score['right'] as num).toInt();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isHost && gameState == GameState.playing) {
      final b = world.children.query<Ball>().firstOrNull;
      if (b != null) {
        service.updateBall({
          'x': b.position.x,
          'y': b.position.y,
        });
      }
      service.updateScore(leftPlayerScore, rightPlayerScore);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    final paddle = findByKey<Paddle>(localKey);
    if (paddle != null) {
      service.updatePaddle(isRight: isHost, y: paddle.position.y);
    }
  }

  @override
  void togglePause() {
    // Pausing disabled in online mode
  }

  @override
  Future<void> onRemove() async {
    await service.dispose();
    await _sub?.cancel();
    super.onRemove();
  }
}
