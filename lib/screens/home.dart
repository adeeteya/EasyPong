import 'package:easy_pong/functions.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Flame.device.setPortrait();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Easy Pong",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 40),
                  TileButton(
                    titleText: "Local Multiplayer",
                    width: isPhone() ? 250 : 350,
                    onTap: () async {
                      await Navigator.of(
                        context,
                      ).pushNamed("/local_multiplayer");
                      await Flame.device.setPortrait();
                    },
                  ),
                  const SizedBox(height: 20),
                  TileButton(
                    titleText: "Online Multiplayer",
                    width: isPhone() ? 250 : 350,
                    onTap: () async {
                      await Navigator.of(
                        context,
                      ).pushNamed('/online_multiplayer');
                      await Flame.device.setPortrait();
                    },
                  ),
                  const SizedBox(height: 20),
                  TileButton(
                    titleText: "Play vs Computer",
                    width: isPhone() ? 250 : 350,
                    onTap: () async {
                      await Navigator.of(
                        context,
                      ).pushNamed('/computer_difficulty');
                      await Flame.device.setPortrait();
                    },
                  ),
                  const SizedBox(height: 20),
                  TileButton(
                    titleText: "Settings",
                    width: isPhone() ? 250 : 350,
                    onTap: () => Navigator.of(context).pushNamed("/settings"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
