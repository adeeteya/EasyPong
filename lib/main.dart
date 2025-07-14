import 'dart:io';

import 'package:easy_pong/firebase_options.dart';
import 'package:easy_pong/models/computer_difficulty.dart';
import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:easy_pong/screens/online_multiplayer.dart';
import 'package:easy_pong/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (!kIsWeb) {
    await FlameAudio.audioCache.load('ping.mp3');
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/local_multiplayer': (context) => const GameApp(),
        '/online_multiplayer': (context) => const OnlineMultiplayerScreen(),
        '/computer_difficulty': (context) => const ComputerDifficultyScreen(),
        '/vs_computer': (context) {
          final difficulty =
              ModalRoute.of(context)?.settings.arguments as ComputerDifficulty?;
          return GameApp(
            vsComputer: true,
            difficulty: difficulty ?? ComputerDifficulty.impossible,
          );
        },
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
