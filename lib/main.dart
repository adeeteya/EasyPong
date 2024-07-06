import 'package:flutter/material.dart';
import 'screens/screens.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_pong/notifiers/settings_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await FlameAudio.audioCache.load("ping.mp3");
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
        // "/versus_computer": (context) => const VersusComputer(),
        "/local_multiplayer": (context) => const GameApp(),
        // "/online_multiplayer": (context) => const OnlineMultiplayer(),
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }
}
