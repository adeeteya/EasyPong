import 'package:easy_pong/components/pong_game.dart';
import 'package:flutter/material.dart';

class PauseButtonOverlay extends StatelessWidget {
  final PongGame game;
  const PauseButtonOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: IconButton(
          icon: const Icon(Icons.pause),
          style: IconButton.styleFrom(
            foregroundColor: game.gameTheme.backgroundColor,
            backgroundColor: game.gameTheme.ballColor,
          ),
          onPressed: game.togglePause,
        ),
      ),
    );
  }
}
