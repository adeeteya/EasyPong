import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum LanRole { host, client }

class LanService {
  LanService.host({this.port = 42124}) : role = LanRole.host;
  LanService.client({this.port = 42124}) : role = LanRole.client;

  final LanRole role;
  final int port;

  RawDatagramSocket? _socket;
  InternetAddress? _peerAddress;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  static const discoveryPort = 42123;
  static const discoveryMessage = 'EASY_PONG_DISCOVER';
  static const discoveryResponse = 'EASY_PONG_FOUND';

  Future<void> start() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _socket!.listen(_onEvent);
    if (role == LanRole.host) {
      _socket!.broadcastEnabled = true;
    }
  }

  void _onEvent(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final dg = _socket!.receive();
      if (dg == null) return;
      final msg = utf8.decode(dg.data);
      if (role == LanRole.host && msg == discoveryMessage) {
        _socket!.send(
          utf8.encode(discoveryResponse),
          dg.address,
          discoveryPort,
        );
      } else {
        _peerAddress ??= dg.address;
        try {
          final decoded = jsonDecode(msg) as Map<String, dynamic>;
          _controller.add(decoded);
        } catch (_) {
          // ignore malformed packet
        }
      }
    }
  }

  Future<InternetAddress?> discoverHost({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final completer = Completer<InternetAddress?>();
    Timer? timer;
    timer = Timer(timeout, () {
      socket.close();
      if (!completer.isCompleted) completer.complete(null);
    });
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = socket.receive();
        if (dg == null) return;
        final msg = utf8.decode(dg.data);
        if (msg == discoveryResponse) {
          timer?.cancel();
          socket.close();
          if (!completer.isCompleted) completer.complete(dg.address);
        }
      }
    });
    socket.send(
      utf8.encode(discoveryMessage),
      InternetAddress('255.255.255.255'),
      discoveryPort,
    );
    return completer.future;
  }

  void send(Map<String, dynamic> data) {
    if (_peerAddress != null && _socket != null) {
      final bytes = utf8.encode(jsonEncode(data));
      _socket!.send(bytes, _peerAddress!, port);
    }
  }

  void dispose() {
    _socket?.close();
    _controller.close();
  }
}
