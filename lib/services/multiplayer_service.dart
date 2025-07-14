import 'package:firebase_database/firebase_database.dart';

class MultiplayerService {
  MultiplayerService(this.roomId)
    : _roomRef = FirebaseDatabase.instance.ref('rooms/$roomId');

  final String roomId;
  final DatabaseReference _roomRef;

  Stream<DatabaseEvent> get roomStream => _roomRef.onValue;

  Future<void> updateState(Map<String, dynamic> data) async {
    await _roomRef.set(data);
  }
}
