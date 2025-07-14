import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseGameService {
  FirebaseGameService(this.roomId, this.playerId);

  final String roomId;
  final String playerId;

  final _roomsRef = FirebaseDatabase.instance.ref('rooms');
  late DatabaseReference _roomRef;
  StreamSubscription<DatabaseEvent>? _sub;

  DatabaseReference get roomRef => _roomRef;

  Future<void> createRoom() async {
    _roomRef = _roomsRef.child(roomId);
    await _roomRef.set({'host': playerId, 'state': 'waiting'});
    await _roomRef.child('host').onDisconnect().remove();
  }

  Future<void> joinRoom() async {
    _roomRef = _roomsRef.child(roomId);
    await _roomRef.child('guest').set(playerId);
    await _roomRef.child('guest').onDisconnect().remove();
  }

  Stream<DatabaseEvent> gameStream() {
    _sub?.cancel();
    _sub = _roomRef.onValue.listen((_) {});
    return _roomRef.onValue;
  }

  Future<void> updatePaddle({required bool isRight, required double y}) async {
    await _roomRef.child('paddles').child(isRight ? 'right' : 'left').set(y);
  }

  Future<void> updateBall(Map<String, dynamic> ball) async {
    await _roomRef.child('ball').set(ball);
  }

  Future<void> updateScore(int left, int right) async {
    await _roomRef.child('score').set({'left': left, 'right': right});
  }

  Future<void> declareWinner(String id) async {
    await _roomRef.child('winner').set(id);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
  }
}
