import 'package:easy_pong/functions.dart';
import 'package:easy_pong/themes/game_theme.dart';
import 'package:flutter/material.dart';

class WelcomeOverlay extends StatelessWidget {
  final GameTheme gameTheme;
  final bool isVsComputer;
  const WelcomeOverlay({
    super.key,
    required this.gameTheme,
    this.isVsComputer = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPhone()) {
      return Center(
        child: Card(
          color: gameTheme.ballColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Tap To Start",
              style: TextStyle(color: gameTheme.backgroundColor),
            ),
          ),
        ),
      );
    }
    return Center(
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "W to Move Up\nS to Move Down",
                style: TextStyle(color: gameTheme.leftHudTextColor),
              ),
            ),
          ),
          Card(
            color: gameTheme.ballColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Tap/Enter To Start",
                style: TextStyle(color: gameTheme.backgroundColor),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                isVsComputer
                    ? "Computer Opponent"
                    : "Up Arrow to Move Up\nDown Arrow to Move Down",
                style: TextStyle(color: gameTheme.leftHudTextColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
