import 'dart:async';
import 'dart:convert';

import 'package:lan_mixed/lan_mixed.dart';

enum LanRole { host, client }

class LanService {
  LanService.host({this.port = 42124}) : role = LanRole.host;
  LanService.client({this.port = 42124}) : role = LanRole.client;

  final LanRole role;
  final int port;

  final LanMixed _lanMixed = LanMixed();
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  List<DeviceEntity> _devices = [];

  Future<void> start() async {
    _lanMixed.startService(
      port: port,
      onReceiveMsg: (msg) {
        if (msg.data != null) {
          try {
            final decoded = jsonDecode(msg.data!) as Map<String, dynamic>;
            _controller.add(decoded);
          } catch (_) {
            // ignore malformed packet
          }
        }
      },
      onDevicesChange: (devices) {
        _devices = devices;
      },
    );
    // Ensure we know about devices on startup
    _lanMixed.refreshDevices();
  }

  Future<String?> discoverHost({Duration timeout = const Duration(seconds: 3)}) async {
    final completer = Completer<String?>();
    final start = DateTime.now();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_devices.isNotEmpty) {
        timer.cancel();
        if (!completer.isCompleted) {
          completer.complete(_devices.first.deviceIp);
        }
      } else if (DateTime.now().difference(start) >= timeout) {
        timer.cancel();
        if (!completer.isCompleted) completer.complete(null);
      }
    });
    _lanMixed.refreshDevices();
    return completer.future;
  }

  void send(Map<String, dynamic> data) {
    _lanMixed.sendMessage(jsonEncode(data));
  }

  void dispose() {
    _lanMixed.close();
    _controller.close();
  }
}
