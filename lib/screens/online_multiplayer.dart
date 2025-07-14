import 'dart:async';

import 'package:easy_pong/screens/game_app.dart';
import 'package:easy_pong/services/lobby_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnlineMultiplayerScreen extends ConsumerStatefulWidget {
  const OnlineMultiplayerScreen({super.key});

  @override
  ConsumerState<OnlineMultiplayerScreen> createState() =>
      _OnlineMultiplayerScreenState();
}

class _OnlineMultiplayerScreenState
    extends ConsumerState<OnlineMultiplayerScreen> {
  late String _userId;
  LobbyService? _lobby;
  StreamSubscription<DatabaseEvent>? _requestSub;

  @override
  void initState() {
    super.initState();
    _initLobby();
  }

  Future<void> _initLobby() async {
    try {
      final auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      user ??= (await auth.signInAnonymously()).user;
      _userId = user!.uid;
      _lobby = LobbyService(_userId);
      await _lobby!.init();
      _requestSub = _lobby!.incomingRequests.listen(_onRequest);
    } catch (e) {
      debugPrint('Lobby initialization failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to lobby')),
        );
        Navigator.pop(context);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _onRequest(DatabaseEvent event) async {
    final fromId = event.snapshot.key;
    if (fromId == null) return;
    final accept = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Match Request'),
            content: Text('$fromId wants to play with you'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Reject'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Accept'),
              ),
            ],
          ),
    );
    if (accept == null) return;
    final roomId = await _lobby!.respondToRequest(fromId, accept);
    if (accept && roomId != null && mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GameApp(roomId: roomId)),
      );
    }
  }

  Future<void> _challenge(String targetId) async {
    if (_lobby == null) return;
    await _lobby!.sendRequest(targetId);
    if (!mounted) return;
    late StreamSubscription sub;
    sub = _lobby!.watchRequestTo(targetId).listen((data) async {
      if (data == null) {
        await sub.cancel();
        if (!mounted) return;
        if (Navigator.canPop(context)) Navigator.pop(context);
      } else if (data['status'] == 'accepted') {
        await sub.cancel();
        final roomId = data['roomId'] as String?;
        if (roomId != null && mounted) {
          Navigator.of(context).pop();
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => GameApp(roomId: roomId)),
          );
        }
      }
    });
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Request Sent'),
            content: const Text('Waiting for response...'),
            actions: [
              TextButton(
                onPressed: () async {
                  await _lobby!.respondToRequest(targetId, false);
                  if (!context.mounted) return;
                  await sub.cancel();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
    await sub.cancel();
  }

  @override
  void dispose() {
    _requestSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_lobby == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Lobby')),
      body: StreamBuilder<List<String>>(
        stream: _lobby!.onlineUsersStream(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No players online'));
          }
          return ListView(
            children: [
              for (final u in users)
                ListTile(
                  title: Text(u),
                  trailing: ElevatedButton(
                    onPressed: () => unawaited(_challenge(u)),
                    child: const Text('Challenge'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
