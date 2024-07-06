import 'dart:async';
import 'package:easy_pong/components/pong_game.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class ImageAssetBackground extends SpriteComponent
    with HasGameReference<PongGame> {
  ImageAssetBackground(this.assetPath) : super();
  final String assetPath;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    final background = await Flame.images.load(assetPath);
    size = game.size;
    sprite = Sprite(background);
  }
}
