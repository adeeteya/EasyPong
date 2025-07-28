import 'package:easy_pong/models/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsModel>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<SettingsModel> {
  @override
  SettingsModel build() {
    final isSfxEnabled =
        ref.read(sharedPreferencesProvider).getBool("isSfxEnabled") ?? true;
    final gameThemeString =
        ref.read(sharedPreferencesProvider).getString("gameTheme") ??
        GameThemeNames.classic.name;
    return SettingsModel(gameThemeString, isSfxEnabled);
  }

  Future toggleSfx() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool("isSfxEnabled", !state.isSfxEnabled);
    state = state.copyWith(isSfxEnabled: !state.isSfxEnabled);
  }

  Future switchGameTheme() async {
    const List<GameThemeNames> gameThemeValues = GameThemeNames.values;
    for (int i = 0; i < gameThemeValues.length; i++) {
      if (i == gameThemeValues.length - 1) {
        await ref
            .read(sharedPreferencesProvider)
            .setString("gameTheme", gameThemeValues[0].name);
        state = state.copyWith(gameThemeName: gameThemeValues[0].name);
        break;
      } else if (state.gameThemeName == gameThemeValues[i].name) {
        await ref
            .read(sharedPreferencesProvider)
            .setString("gameTheme", gameThemeValues[i + 1].name);
        state = state.copyWith(gameThemeName: gameThemeValues[i + 1].name);
        break;
      }
    }
  }
}
