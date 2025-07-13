import 'package:easy_pong/full_screen_helper.dart';
import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:easy_pong/screens/screens.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFullScreen();
  if (!kIsWeb) {
    await FlameAudio.audioCache.load('ping.mp3');
  }
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const EasyPongApp(),
    ),
  );
}

class EasyPongApp extends StatelessWidget {
  const EasyPongApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Pong',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'AtariClassic',
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const HomeScreen(),
        "/local_multiplayer": (context) => const GameApp(),
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }
}
