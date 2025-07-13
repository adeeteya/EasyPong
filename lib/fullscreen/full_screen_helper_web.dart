// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> fullScreenImplementation() async {
  await html.document.documentElement?.requestFullscreen();
}
