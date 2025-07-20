import 'package:easy_pong/functions.dart';
import 'package:easy_pong/themes/game_theme.dart';
import 'package:flutter/material.dart';

class WaitingForHostOverlay extends StatelessWidget {
  final GameTheme gameTheme;
  const WaitingForHostOverlay({super.key, required this.gameTheme});

  @override
  Widget build(BuildContext context) {
    if (isPhone()) {
      return Center(
        child: Card(
          color: gameTheme.ballColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Waiting for host to start the game',
              style: TextStyle(color: gameTheme.backgroundColor),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Center(
      child: Card(
        color: gameTheme.ballColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Waiting for host to start the game',
            style: TextStyle(color: gameTheme.backgroundColor),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
