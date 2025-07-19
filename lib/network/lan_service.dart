import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

enum LanRole { host, client }

class LanService {
  LanService.host() : role = LanRole.host;
  LanService.client() : role = LanRole.client;

  final LanRole role;

  final _nearbyService = NearbyService();
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _controller.stream;

  StreamSubscription? _stateSub;
  StreamSubscription? _dataSub;
  Device? _peerDevice;
  Completer<void>? _connectCompleter;

  Future<void> start() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceName = 'Unknown';
    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      deviceName = info.model;
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      deviceName = info.localizedModel;
    }

    _connectCompleter = Completer<void>();
    await _nearbyService.init(
      serviceType: 'easy-pong',
      deviceName: deviceName,
      strategy: Strategy.P2P_CLUSTER,
      callback: (isRunning) async {
        if (isRunning) {
          if (role == LanRole.host) {
            await _nearbyService.startAdvertisingPeer();
            await _nearbyService.startBrowsingForPeers();
          } else {
            await _nearbyService.startBrowsingForPeers();
          }
        }
      },
    );

    _dataSub = _nearbyService.dataReceivedSubscription(
      callback: (data) {
        final msg = data['message'] as String?;
        if (msg != null) {
          try {
            final decoded = jsonDecode(msg) as Map<String, dynamic>;
            _controller.add(decoded);
          } catch (_) {
            // ignore malformed packet
          }
        }
      },
    );

    _stateSub = _nearbyService.stateChangedSubscription(
      callback: (devices) async {
        for (final device in devices) {
          if (device.state == SessionState.connected) {
            _peerDevice = device;
            if (!(_connectCompleter?.isCompleted ?? true)) {
              _connectCompleter!.complete();
            }
          } else if (role == LanRole.client &&
              device.state == SessionState.notConnected) {
            await _nearbyService.invitePeer(
              deviceID: device.deviceId,
              deviceName: device.deviceName,
            );
          }
        }
      },
    );
  }

  Future<void> waitForConnection() async {
    await _connectCompleter?.future;
  }

  void send(Map<String, dynamic> data) {
    if (_peerDevice != null) {
      _nearbyService.sendMessage(_peerDevice!.deviceId, jsonEncode(data));
    }
  }

  void dispose() {
    _stateSub?.cancel();
    _dataSub?.cancel();
    _nearbyService.stopAdvertisingPeer();
    _nearbyService.stopBrowsingForPeers();
    _controller.close();
  }
}
