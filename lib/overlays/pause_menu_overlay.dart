import 'package:easy_pong/components/pong_game.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flutter/material.dart';

class PauseMenuOverlay extends StatelessWidget {
  final PongGame game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = game.gameTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TileButton(
            titleText: 'Restart Game',
            width: 200,
            borderColor: theme.backgroundColor,
            tileBackgroundColor: theme.ballColor,
            onTap: () {
              game.overlays.remove('PauseMenuOverlay');
              game.startGame();
              game.resumeEngine();
            },
          ),
          const SizedBox(height: 20),
          TileButton(
            titleText: 'Quit Game',
            width: 200,
            borderColor: theme.backgroundColor,
            tileBackgroundColor: theme.ballColor,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
