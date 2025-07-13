import 'dart:io';

import 'package:flame/flame.dart';
import 'package:window_manager/window_manager.dart';

Future<void> fullScreenImplementation() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(fullScreen: true),
      () async {
        await windowManager.show();
      },
    );
  } else {
    await Flame.device.fullScreen();
  }
}
