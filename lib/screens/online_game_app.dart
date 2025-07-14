import 'dart:io';
import 'dart:math' as math;

import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:easy_pong/online/firebase_game_service.dart';
import 'package:easy_pong/online/online_pong_game.dart';
import 'package:easy_pong/overlays/winner_overlay.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnlineGameApp extends ConsumerStatefulWidget {
  const OnlineGameApp({super.key, required this.service, required this.isHost});

  final FirebaseGameService service;
  final bool isHost;

  @override
  ConsumerState<OnlineGameApp> createState() => _OnlineGameAppState();
}

class _OnlineGameAppState extends ConsumerState<OnlineGameApp> {
  late final OnlinePongGame _game;

  @override
  void initState() {
    super.initState();
    Flame.device.setLandscape();
    _game = OnlinePongGame(
      isMobile: (!kIsWeb) && (Platform.isAndroid || Platform.isIOS),
      isSfxEnabled: ref.read(settingsProvider).isSfxEnabled,
      gameTheme: ref.read(settingsProvider).getGameTheme(),
      service: widget.service,
      isHost: widget.isHost,
    );
  }

  @override
  void dispose() {
    _game.pauseEngine();
    _game.overlays.clear();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await widget.service.declareWinner('opponent');
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
        body: Builder(
          builder: (context) {
            final padding = MediaQuery.paddingOf(context);
            final maxPadding = math.max(padding.left, padding.right);
            _game.horizontalSafeArea = math.max(maxPadding, 20);
            return GameWidget(
              game: _game,
              overlayBuilderMap: {
                GameState.gameOver.name: (context, game) {
                  final g = game as OnlinePongGame;
                  return WinnerOverlay(
                    gameTheme: g.gameTheme,
                    leftPlayerScore: g.leftPlayerScore,
                    rightPlayerScore: g.rightPlayerScore,
                    gameReplayPressed: () {},
                  );
                },
              },
            );
          },
        ),
      ),
    );
  }
}
