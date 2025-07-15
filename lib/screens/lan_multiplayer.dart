import 'package:easy_pong/network/lan_service.dart';
import 'package:easy_pong/screens/game_app.dart';
import 'package:flutter/material.dart';

class LanMultiplayerScreen extends StatefulWidget {
  const LanMultiplayerScreen({super.key});

  @override
  State<LanMultiplayerScreen> createState() => _LanMultiplayerScreenState();
}

class _LanMultiplayerScreenState extends State<LanMultiplayerScreen> {
  LanService? _service;
  String? _hostAddress;
  final TextEditingController _ipController = TextEditingController();
  bool _hosting = false;
  String? _status;

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  Future<void> _hostGame() async {
    _service = LanService.host();
    await _service!.startHost();
    _hosting = true;
    _status = 'Waiting for opponent...';
    _hostAddress = await _service!.hostAddress();
    setState(() {});
    _service!.messages.listen((msg) {
      if (mounted && msg != 'disconnect') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => GameApp(
              lanService: _service,
              isHost: true,
            ),
          ),
        );
      }
    });
  }

  Future<void> _joinGame() async {
    final ip = _ipController.text;
    if (ip.isEmpty) return;
    _service = LanService.client();
    await _service!.connect(ip);
    _service!.send({'type': 'hello'});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => GameApp(
          lanService: _service,
          isHost: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LAN Multiplayer')),
      body: Center(
        child: _hosting
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hostAddress != null)
                    Text('Your IP: $_hostAddress'),
                  const SizedBox(height: 10),
                  Text(_status ?? ''),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _hostGame,
                    child: const Text('Host Game'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ipController,
                    decoration: const InputDecoration(
                      labelText: 'Host IP',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _joinGame,
                    child: const Text('Join Game'),
                  ),
                ],
              ),
      ),
    );
  }
}
