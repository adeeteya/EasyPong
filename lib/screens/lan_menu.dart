import 'dart:async';

import 'package:easy_pong/functions.dart';
import 'package:easy_pong/network/lan_service.dart';
import 'package:easy_pong/screens/game_app.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:flutter/material.dart';

class LanMenuScreen extends StatefulWidget {
  const LanMenuScreen({super.key});

  @override
  State<LanMenuScreen> createState() => _LanMenuScreenState();
}

class _LanMenuScreenState extends State<LanMenuScreen> {
  String _status = '';

  Future<void> _hostGame() async {
    final service = LanService.host();
    setState(() => _status = 'Waiting for opponent...');
    await service.start();
    late StreamSubscription sub;
    sub = service.messages.listen((event) {
      if (event['type'] == 'start') {
        sub.cancel();
        if (!mounted) return;
        unawaited(
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => GameApp(lanService: service, isHost: true),
            ),
          ),
        );
      }
    });
  }

  Future<void> _joinGame() async {
    final service = LanService.client();
    setState(() => _status = 'Searching...');
    await service.start();
    final host = await service.discoverHost();
    if (host == null) {
      setState(() => _status = 'No host found');
      service.dispose();
      return;
    }
    service.send({'type': 'start'});
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GameApp(lanService: service)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LAN Multiplayer')),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Column(
            children: [
              const Spacer(),
              TileButton(
                titleText: 'Host Game',
                width: isPhone() ? 250 : 350,
                onTap: _hostGame,
              ),
              const SizedBox(height: 20),
              TileButton(
                titleText: 'Join Game',
                width: isPhone() ? 250 : 350,
                onTap: _joinGame,
              ),
              const SizedBox(height: 20),
              Text(_status),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
