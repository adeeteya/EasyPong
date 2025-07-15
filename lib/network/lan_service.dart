import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class LanService {
  final bool isHost;
  final int port;
  ServerSocket? _server;
  Socket? _socket;
  final StreamController<String> _controller = StreamController.broadcast();

  LanService.host({this.port = 4567}) : isHost = true;
  LanService.client({this.port = 4567}) : isHost = false;

  Stream<String> get messages => _controller.stream;

  Future<void> startHost() async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _server!.listen((client) {
      _socket = client;
      client.listen(_onData, onDone: _onDone, onError: (_) => _onDone());
    });
  }

  Future<void> connect(String host) async {
    try {
      _socket =
          await Socket.connect(host, port).timeout(const Duration(seconds: 5));
      _socket!.listen(_onData, onDone: _onDone, onError: (_) => _onDone());
    } catch (e) {
      _controller.addError(e);
      rethrow;
    }
  }

  void send(Map<String, dynamic> data) {
    final jsonData = jsonEncode(data);
    _socket?.write('$jsonData\n');
  }

  void _onData(Uint8List data) {
    final msg = utf8.decode(data).trim();
    if (msg.isNotEmpty) {
      _controller.add(msg);
    }
  }

  void _onDone() {
    _controller.add('disconnect');
  }

  Future<String> hostAddress() async {
    final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final interface in interfaces) {
      for (final addr in interface.addresses) {
        if (!addr.isLoopback) return addr.address;
      }
    }
    return '0.0.0.0';
  }

  void dispose() {
    _socket?.destroy();
    _server?.close();
  }
}
