import 'dart:async';

import 'package:easy_pong/p2p/p2p_manager.dart';
import 'package:easy_pong/screens/real_time_game_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class RealTimeConnectionScreen extends StatefulWidget {
  const RealTimeConnectionScreen({super.key});

  @override
  State<RealTimeConnectionScreen> createState() =>
      _RealTimeConnectionScreenState();
}

class _RealTimeConnectionScreenState extends State<RealTimeConnectionScreen> {
  P2pManager? manager;
  List<BleDiscoveredDevice> devices = [];
  bool hosting = false;
  bool joining = false;

  Future<bool> _requestPermissions() async {
    final granted = await P2pManager.ensurePermissions();
    if (!granted && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Required permissions not granted.')),
      );
    }
    return granted;
  }

  @override
  void dispose() {
    manager?.dispose();
    super.dispose();
  }

  Future<void> _hostGame() async {
    if (!await _requestPermissions()) return;
    manager = P2pManager.host();
    await manager!.initialize();
    await manager!.createGroup();
    setState(() {
      hosting = true;
    });
    manager!.onOpponentLeft = () {
      if (mounted) Navigator.of(context).pop();
    };
    manager!.messages.listen((event) {});
    manager!.clientListStream?.listen((clients) {
      if (clients.isNotEmpty && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => RealTimeGameApp(manager: manager!, isHost: true),
          ),
        );
      }
    });
  }

  Future<void> _joinGame() async {
    if (!await _requestPermissions()) return;
    manager = P2pManager.client();
    await manager!.initialize();
    setState(() {
      joining = true;
    });
    unawaited(
      manager!.startScan((list) {
        setState(() {
          devices = list;
        });
      }),
    );
  }

  Future<void> _connect(BleDiscoveredDevice device) async {
    await manager!.connectDevice(device);
    if (mounted) {
      unawaited(
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => RealTimeGameApp(manager: manager!, isHost: false),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hosting) {
      return const Scaffold(
        body: Center(child: Text('Waiting for opponent...')),
      );
    }
    if (joining) {
      return Scaffold(
        appBar: AppBar(title: const Text('Select Host')),
        body: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final d = devices[index];
            return ListTile(
              title: Text(d.deviceName),
              onTap: () => _connect(d),
            );
          },
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Realtime Multiplayer')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _hostGame,
              child: const Text('Host Game'),
            ),
            const SizedBox(height: 20),
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
