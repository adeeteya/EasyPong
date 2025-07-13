import 'package:easy_pong/fullscreen/full_screen_helper_stub.dart'
    if (dart.library.html) 'package:easy_pong/fullscreen/full_screen_helper_web.dart'
    if (dart.library.io) 'package:easy_pong/fullscreen/full_screen_helper_io.dart';

Future<void> initFullScreen() => fullScreenImplementation();
