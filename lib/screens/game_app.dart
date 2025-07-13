import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:easy_pong/overlays/welcome_overlay.dart';
import 'package:easy_pong/overlays/winner_overlay.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameState { welcome, gameOver, playing }

class GameApp extends ConsumerWidget {
  const GameApp({super.key});

  @override
  ConsumerStatefulElement createElement() {
    Flame.device.setLandscape();
    return super.createElement();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GameWidget(
              game: PongGame(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                isSfxEnabled: ref.read(settingsProvider).isSfxEnabled,
                gameTheme: ref.read(settingsProvider).getGameTheme(),
              ),
              overlayBuilderMap: {
                GameState.welcome.name: (context, PongGame game) =>
                    WelcomeOverlay(gameTheme: game.gameTheme),
                GameState.gameOver.name: (context, PongGame game) =>
                    WinnerOverlay(
                      gameTheme: game.gameTheme,
                      leftPlayerScore: game.leftPlayerScore,
                      rightPlayerScore: game.rightPlayerScore,
                      gameReplayPressed: () {
                        game.overlays.clear();
                        game.gameState = GameState.welcome;
                      },
                    ),
              },
            );
          },
        ),
      ),
    );
  }
}
