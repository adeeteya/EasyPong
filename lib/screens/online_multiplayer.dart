import 'dart:async';
import 'dart:math';
import 'package:easy_pong/functions.dart';
import 'package:easy_pong/online/firebase_game_service.dart';
import 'package:easy_pong/screens/online_game_app.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flutter/material.dart';

class OnlineMultiplayerScreen extends StatefulWidget {
  const OnlineMultiplayerScreen({super.key});

  @override
  State<OnlineMultiplayerScreen> createState() =>
      _OnlineMultiplayerScreenState();
}

class _OnlineMultiplayerScreenState extends State<OnlineMultiplayerScreen> {
  String get _randomRoom => Random().nextInt(999999).toString().padLeft(6, '0');

  Future<void> _startGame(FirebaseGameService service, bool isHost) async {
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OnlineGameApp(service: service, isHost: isHost),
      ),
    );
  }

  Future<void> _createRoom() async {
    final id = _randomRoom;
    final service = FirebaseGameService(id, _randomRoom);
    await service.createRoom();
    if (!mounted) return;
    late final StreamSubscription sub;
    sub = service.roomRef.child('guest').onValue.listen((event) async {
      if (event.snapshot.value != null) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(true);
        }
      }
    });
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Room ID'),
          content: SelectableText(id),
          actions: [
            TextButton(
              onPressed: () async {
                await sub.cancel();
                await service.deleteRoom();
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).pop(false);
                }
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
    await sub.cancel();
    if (result == true) {
      await _startGame(service, true);
    }
  }

  Future<void> _joinRoom() async {
    final controller = TextEditingController();
    final id = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          title: const Text('Join Room'),
          content: TextField(
            controller: controller,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Room ID'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.length == 6) {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pop(controller.text);
                }
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
    if (id == null) return;
    final service = FirebaseGameService(id, _randomRoom);
    await service.joinRoom();
    if (!mounted) return;
    await _startGame(service, false);
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
                  'Online Multiplayer',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                TileButton(
                  titleText: 'Create Room',
                  width: isPhone() ? 250 : 350,
                  onTap: _createRoom,
                ),
                const SizedBox(height: 20),
                TileButton(
                  titleText: 'Join Room',
                  width: isPhone() ? 250 : 350,
                  onTap: _joinRoom,
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
