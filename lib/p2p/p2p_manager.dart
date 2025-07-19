import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class P2pManager {
  final bool isHost;
  FlutterP2pHost? _host;
  FlutterP2pClient? _client;

  static final FlutterP2pHost _permissionsHelper = FlutterP2pHost();

  static Future<bool> ensurePermissions() async {
    var storageGranted = await _permissionsHelper.checkStoragePermission();
    if (!storageGranted) {
      storageGranted = await _permissionsHelper.askStoragePermission();
    }

    var p2pGranted = await _permissionsHelper.checkP2pPermissions();
    if (!p2pGranted) {
      p2pGranted = await _permissionsHelper.askP2pPermissions();
    }

    var bluetoothGranted = await _permissionsHelper.checkBluetoothPermissions();
    if (!bluetoothGranted) {
      bluetoothGranted = await _permissionsHelper.askBluetoothPermissions();
    }

    return storageGranted && p2pGranted && bluetoothGranted;
  }

  final _controller = StreamController<String>.broadcast();
  Stream<String> get messages => _controller.stream;
  void Function()? onOpponentLeft;

  P2pManager.host() : isHost = true;
  P2pManager.client() : isHost = false;

  Stream<List<P2pClientInfo>>? get clientListStream =>
      _host?.streamClientList();

  Future<void> initialize() async {
    if (isHost) {
      _host = FlutterP2pHost();
      await _host!.initialize();
      _host!.streamReceivedTexts().listen(_controller.add);
      _host!.streamClientList().listen((clients) {
        if (clients.isEmpty) {
          onOpponentLeft?.call();
        }
      });
    } else {
      _client = FlutterP2pClient();
      await _client!.initialize();
      _client!.streamReceivedTexts().listen(_controller.add);
      _client!.streamHotspotState().listen((state) {
        if (!state.isActive) {
          onOpponentLeft?.call();
        }
      });
    }
  }

  Future<void> createGroup() async {
    if (isHost) {
      await _host?.createGroup();
    }
  }

  Future<void> startScan(
    Function(List<BleDiscoveredDevice>) result, {
    Function()? onDone,
    Function(dynamic)? onError,
  }) async {
    if (!isHost) {
      await _client?.startScan(result, onDone: onDone, onError: onError);
    }
  }

  Future<void> connectDevice(BleDiscoveredDevice device) async {
    if (!isHost) {
      await _client?.connectWithDevice(device);
    }
  }

  Future<void> send(String text) async {
    if (isHost) {
      await _host?.broadcastText(text);
    } else {
      await _client?.broadcastText(text);
    }
  }

  Future<void> dispose() async {
    await _host?.dispose();
    await _client?.dispose();
    await _controller.close();
  }
}
