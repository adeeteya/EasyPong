import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class LobbyService {
  LobbyService(this.userId) : _db = FirebaseDatabase.instance;

  final String userId;
  final FirebaseDatabase _db;
  DatabaseReference? _presenceRef;

  Future<void> init() async {
    _presenceRef = _db.ref('lobby/users/$userId');
    await _presenceRef!.set(true);
    await _presenceRef!.onDisconnect().remove();
  }

  Stream<List<String>> onlineUsersStream() {
    return _db.ref('lobby/users').onValue.map((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        final ids = value.keys.cast<String>().toList();
        ids.remove(userId);
        return ids;
      }
      return <String>[];
    });
  }

  Stream<DatabaseEvent> get incomingRequests =>
      _db.ref('lobby/requests/$userId').onChildAdded;

  Stream<Map<String, dynamic>?> watchRequestFrom(String fromId) {
    return _db.ref('lobby/requests/$userId/$fromId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    });
  }

  Stream<Map<String, dynamic>?> watchRequestTo(String targetId) {
    return _db.ref('lobby/requests/$targetId/$userId').onValue.map((event) {
      final data = event.snapshot.value;
      if (data is Map) return Map<String, dynamic>.from(data);
      return null;
    });
  }

  Future<void> sendRequest(String targetId) async {
    await _db.ref('lobby/requests/$targetId/$userId').set({
      'status': 'pending',
    });
  }

  Future<String?> respondToRequest(String fromId, bool accept) async {
    final ref = _db.ref('lobby/requests/$userId/$fromId');
    if (!accept) {
      await ref.remove();
      return null;
    }
    final roomRef = _db.ref('rooms').push();
    await roomRef.set({'createdAt': DateTime.now().toIso8601String()});
    final data = {'status': 'accepted', 'roomId': roomRef.key};
    await ref.set(data);
    await _db.ref('lobby/requests/$fromId/$userId').set(data);
    return roomRef.key;
  }
}
