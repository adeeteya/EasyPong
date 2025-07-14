import 'package:easy_pong/components/components.dart';
import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/services/multiplayer_service.dart';
import 'package:flame/components.dart';

/// Variant of [PongGame] that synchronizes state over the network using a
/// [MultiplayerService].
class MultiplayerPongGame extends PongGame {
  MultiplayerPongGame({
    required super.isMobile,
    required super.isSfxEnabled,
    required super.gameTheme,
    required this.service,
  }) : super(vsComputer: false);

  final MultiplayerService service;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    service.onData = _handleRemoteData;
    await service.connect();
  }

  void _handleRemoteData(Map<String, dynamic> data) {
    final left = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
    final right = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
    final balls = world.children.query<Ball>();
    if (data['leftPaddleY'] != null && left != null) {
      left.position.y = (data['leftPaddleY'] as num).toDouble();
    }
    if (data['rightPaddleY'] != null && right != null) {
      right.position.y = (data['rightPaddleY'] as num).toDouble();
    }
    if (balls.isNotEmpty && data['ballX'] != null && data['ballY'] != null) {
      final ball = balls.first;
      ball.position.setValues(
        (data['ballX'] as num).toDouble(),
        (data['ballY'] as num).toDouble(),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final left = findByKey<Paddle>(ComponentKey.named('LeftPaddle'));
    final right = findByKey<Paddle>(ComponentKey.named('RightPaddle'));
    final balls = world.children.query<Ball>();
    service.send({
      'leftPaddleY': left?.position.y,
      'rightPaddleY': right?.position.y,
      'ballX': balls.isNotEmpty ? balls.first.position.x : null,
      'ballY': balls.isNotEmpty ? balls.first.position.y : null,
      'leftScore': leftPlayerScore,
      'rightScore': rightPlayerScore,
    });
  }

  @override
  void onRemove() {
    service.close();
    super.onRemove();
  }
}
