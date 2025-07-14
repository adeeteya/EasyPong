import 'package:easy_pong/functions.dart';
import 'package:easy_pong/models/computer_difficulty.dart';
import 'package:easy_pong/screens/game_app.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class ComputerDifficultyScreen extends StatelessWidget {
  const ComputerDifficultyScreen({super.key});

  Future<void> _startGame(
    BuildContext context,
    ComputerDifficulty difficulty,
  ) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameApp(vsComputer: true, difficulty: difficulty),
      ),
    );
    await Flame.device.setPortrait();
  }

  @override
  Widget build(BuildContext context) {
    Flame.device.setPortrait();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                const Spacer(flex: 3),
                Text(
                  'Select Difficulty',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                TileButton(
                  titleText: 'Easy',
                  width: isPhone() ? 250 : 350,
                  onTap: () => _startGame(context, ComputerDifficulty.easy),
                ),
                const SizedBox(height: 20),
                TileButton(
                  titleText: 'Medium',
                  width: isPhone() ? 250 : 350,
                  onTap: () => _startGame(context, ComputerDifficulty.medium),
                ),
                const SizedBox(height: 20),
                TileButton(
                  titleText: 'Impossible',
                  width: isPhone() ? 250 : 350,
                  onTap:
                      () => _startGame(context, ComputerDifficulty.impossible),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
