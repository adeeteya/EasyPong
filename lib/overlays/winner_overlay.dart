import 'package:easy_pong/themes/game_theme.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WinnerOverlay extends StatelessWidget {
  final GameTheme gameTheme;
  final int leftPlayerScore;
  final int rightPlayerScore;
  final bool isVsComputer;
  final VoidCallback gameReplayPressed;
  const WinnerOverlay({
    super.key,
    required this.gameTheme,
    required this.leftPlayerScore,
    required this.rightPlayerScore,
    this.isVsComputer = false,
    required this.gameReplayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: AnimateList(
          effects: [FadeEffect(duration: 300.ms)],
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$leftPlayerScore",
                    style: TextStyle(
                      color: gameTheme.leftHudTextColor,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    (leftPlayerScore >= rightPlayerScore)
                        ? "You\nWin"
                        : "You\nLose",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gameTheme.leftHudTextColor,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TileButton(
                    titleText: "Play Again",
                    width: 200,
                    borderColor: gameTheme.backgroundColor,
                    tileBackgroundColor: gameTheme.ballColor,
                    onTap: gameReplayPressed,
                  ),
                  const SizedBox(height: 20),
                  TileButton(
                    titleText: "Quit",
                    width: 200,
                    borderColor: gameTheme.backgroundColor,
                    tileBackgroundColor: gameTheme.ballColor,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$rightPlayerScore",
                    style: TextStyle(
                      color: gameTheme.rightHudTextColor,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isVsComputer
                        ? (rightPlayerScore > leftPlayerScore
                            ? "Computer\nWins"
                            : "Computer\nLoses")
                        : (rightPlayerScore > leftPlayerScore
                            ? "You\nWin"
                            : "You\nLose"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: gameTheme.rightHudTextColor,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
