import 'dart:io';

import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/models/computer_difficulty.dart';
import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:easy_pong/overlays/welcome_overlay.dart';
import 'package:easy_pong/overlays/winner_overlay.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GameState { welcome, gameOver, playing }

class GameApp extends ConsumerStatefulWidget {
  final bool vsComputer;
  final ComputerDifficulty difficulty;
  const GameApp({
    super.key,
    this.vsComputer = false,
    this.difficulty = ComputerDifficulty.impossible,
  });

  @override
  ConsumerState<GameApp> createState() => _GameAppState();
}

class _GameAppState extends ConsumerState<GameApp> {
  late final PongGame _game;

  @override
  void initState() {
    super.initState();
    Flame.device.setLandscape();
    _game = PongGame(
      isMobile: (!kIsWeb) && (Platform.isAndroid || Platform.isIOS),
      isSfxEnabled: ref.read(settingsProvider).isSfxEnabled,
      gameTheme: ref.read(settingsProvider).getGameTheme(),
      vsComputer: widget.vsComputer,
      difficulty: widget.difficulty,
    );
  }

  Future<bool> _onWillPop() async {
    if (_game.gameState == GameState.playing) {
      _game.pauseEngine();
      final quit = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Quit Game?'),
              content: const Text('Do you want to quit the current game?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
      );
      if (quit != true) {
        _game.resumeEngine();
        return false;
      }
      return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await _onWillPop()) {
          if (mounted) navigator.pop(result);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: GameWidget(
            game: _game,
            overlayBuilderMap: {
              GameState.welcome.name:
                  (context, PongGame game) => WelcomeOverlay(
                    gameTheme: game.gameTheme,
                    isVsComputer: game.vsComputer,
                  ),
              GameState.gameOver.name:
                  (context, PongGame game) => WinnerOverlay(
                    gameTheme: game.gameTheme,
                    leftPlayerScore: game.leftPlayerScore,
                    rightPlayerScore: game.rightPlayerScore,
                    isVsComputer: game.vsComputer,
                    gameReplayPressed: () {
                      game.overlays.clear();
                      game.gameState = GameState.welcome;
                    },
                  ),
            },
          ),
        ),
      ),
    );
  }
}
