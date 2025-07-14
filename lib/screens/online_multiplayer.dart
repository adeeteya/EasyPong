import 'package:easy_pong/screens/game_app.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OnlineMultiplayerScreen extends StatefulWidget {
  const OnlineMultiplayerScreen({super.key});

  @override
  State<OnlineMultiplayerScreen> createState() =>
      _OnlineMultiplayerScreenState();
}

class _OnlineMultiplayerScreenState extends State<OnlineMultiplayerScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _createRoom() async {
    final roomRef = FirebaseDatabase.instance.ref('rooms').push();
    await roomRef.set({'createdAt': DateTime.now().toIso8601String()});
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameApp(roomId: roomRef.key)),
    );
  }

  void _joinRoom() {
    final id = _controller.text.trim();
    if (id.isEmpty) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => GameApp(roomId: id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Multiplayer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Room ID'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _joinRoom,
              child: const Text('Join Room'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createRoom,
              child: const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }
}
