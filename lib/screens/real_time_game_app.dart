import 'dart:io';

import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:easy_pong/p2p/p2p_manager.dart';
import 'package:easy_pong/p2p/real_time_pong_game.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RealTimeGameApp extends ConsumerStatefulWidget {
  final P2pManager manager;
  final bool isHost;
  const RealTimeGameApp({
    super.key,
    required this.manager,
    required this.isHost,
  });

  @override
  ConsumerState<RealTimeGameApp> createState() => _RealTimeGameAppState();
}

class _RealTimeGameAppState extends ConsumerState<RealTimeGameApp> {
  late final RealTimePongGame _game;

  @override
  void initState() {
    super.initState();
    Flame.device.setLandscape();
    _game = RealTimePongGame(
      manager: widget.manager,
      isHost: widget.isHost,
      isMobile: (!kIsWeb) && (Platform.isAndroid || Platform.isIOS),
      isSfxEnabled: ref.read(settingsProvider).isSfxEnabled,
      gameTheme: ref.read(settingsProvider).getGameTheme(),
    );
  }

  @override
  void dispose() {
    _game.pauseEngine();
    _game.overlays.clear();
    widget.manager.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
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
        body: GameWidget<RealTimePongGame>(
          game: _game,
          overlayBuilderMap: const {},
        ),
      ),
    );
  }
}
