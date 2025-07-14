import 'dart:math';
import 'package:easy_pong/functions.dart';
import 'package:easy_pong/online/firebase_game_service.dart';
import 'package:easy_pong/screens/online_game_app.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flutter/material.dart';

class OnlineMultiplayerScreen extends StatefulWidget {
  const OnlineMultiplayerScreen({super.key});

  @override
  State<OnlineMultiplayerScreen> createState() => _OnlineMultiplayerScreenState();
}

class _OnlineMultiplayerScreenState extends State<OnlineMultiplayerScreen> {
  final roomController = TextEditingController();

  String get _randomRoom => Random().nextInt(999999).toString().padLeft(6, '0');

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
                  'Online Multiplayer',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: TextField(
                    controller: roomController,
                    decoration: const InputDecoration(labelText: 'Room ID'),
                  ),
                ),
                const SizedBox(height: 20),
                TileButton(
                  titleText: 'Create Room',
                  width: isPhone() ? 250 : 350,
                  onTap: () async {
                    final id = roomController.text.isEmpty ? _randomRoom : roomController.text;
                    final service = FirebaseGameService(id, _randomRoom);
                    await service.createRoom();
                    if (context.mounted) {
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => OnlineGameApp(service: service, isHost: true),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                TileButton(
                  titleText: 'Join Room',
                  width: isPhone() ? 250 : 350,
                  onTap: () async {
                    final id = roomController.text;
                    if (id.isEmpty) return;
                    final service = FirebaseGameService(id, _randomRoom);
                    await service.joinRoom();
                    if (context.mounted) {
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => OnlineGameApp(service: service, isHost: false),
                        ),
                      );
                    }
                  },
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
