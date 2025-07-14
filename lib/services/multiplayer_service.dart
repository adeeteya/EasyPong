import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class MultiplayerService {
  MultiplayerService(this.roomId)
      : _roomRef = FirebaseDatabase.instance.ref('rooms/$roomId'),
        _stateRef =
            FirebaseDatabase.instance.ref('rooms/$roomId/state');

  final String roomId;
  final DatabaseReference _roomRef;
  final DatabaseReference _stateRef;

  /// Stream of score updates for backward compatibility.
  Stream<DatabaseEvent> get roomStream => _roomRef.onValue;

  StreamSubscription<DatabaseEvent>? _sub;

  /// Callback invoked whenever new game state is received.
  void Function(Map<String, dynamic> data)? onData;

  /// Updates the score in the database.
  Future<void> updateState(Map<String, dynamic> data) async {
    await _roomRef.set(data);
  }

  /// Connects to the realtime state channel and starts listening.
  Future<void> connect() async {
    _sub = _stateRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        onData?.call(Map<String, dynamic>.from(value));
      }
    });
  }

  /// Sends the local game state to the remote player.
  Future<void> send(Map<String, dynamic> data) async {
    await _stateRef.set(data);
  }

  /// Stops listening for updates.
  Future<void> close() async {
    await _sub?.cancel();
  }
}
