import 'package:easy_pong/functions.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  StatelessElement createElement() {
    Flame.device.setPortrait();
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                const Spacer(flex: 3),
                Text(
                  "Easy Pong",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const Spacer(),
                TileButton(
                  titleText: "Local Multiplayer",
                  width: isPhone() ? 250 : 350,
                  onTap: () async {
                    await Navigator.of(context).pushNamed("/local_multiplayer");
                    await Flame.device.setPortrait();
                  },
                ),
                const SizedBox(height: 20),
                TileButton(
                  titleText: "Play vs Computer",
                  width: isPhone() ? 250 : 350,
                  onTap: () async {
                    await Navigator.of(context).pushNamed("/vs_computer");
                    await Flame.device.setPortrait();
                  },
                ),
                const SizedBox(height: 20),
                TileButton(
                  titleText: "Settings",
                  width: isPhone() ? 250 : 350,
                  onTap: () => Navigator.of(context).pushNamed("/settings"),
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
