import 'package:easy_pong/functions.dart';
import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:easy_pong/widgets/tile_button.dart';
import 'package:easy_pong/widgets/tile_checkbox_button.dart';
import 'package:easy_pong/widgets/tile_value_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsModel = ref.watch(settingsProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                const Spacer(flex: 3),
                Text(
                  "Settings",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const Spacer(),
                TileButton(
                  titleText: "Back To Menu",
                  width: isPhone() ? 250 : 350,
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),
                TileValueButton(
                  titleText: "Theme",
                  valueText: settingsModel.gameThemeName.toLowerCase(),
                  width: isPhone() ? 250 : 350,
                  onTap: () =>
                      ref.read(settingsProvider.notifier).switchGameTheme(),
                ),
                const SizedBox(height: 20),
                TileCheckboxButton(
                  titleText: "SFX",
                  width: isPhone() ? 250 : 350,
                  isChecked: settingsModel.isSfxEnabled,
                  onTap: () => ref.read(settingsProvider.notifier).toggleSfx(),
                ),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
