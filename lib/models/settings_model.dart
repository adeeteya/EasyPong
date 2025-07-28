import 'package:easy_pong/themes/themes.dart';

enum GameThemeNames {
  classic,
  modern,
  football,
  matrix,
  brownBg,
  yellowBg,
  inverted,
}

class SettingsModel {
  final String gameThemeName;
  final bool isSfxEnabled;

  SettingsModel(this.gameThemeName, this.isSfxEnabled);

  SettingsModel copyWith({String? gameThemeName, bool? isSfxEnabled}) {
    return SettingsModel(
      gameThemeName ?? this.gameThemeName,
      isSfxEnabled ?? this.isSfxEnabled,
    );
  }

  GameTheme getGameTheme() {
    if (GameThemeNames.classic.name == gameThemeName) {
      return ClassicTheme();
    } else if (GameThemeNames.modern.name == gameThemeName) {
      return ModernTheme();
    } else if (GameThemeNames.football.name == gameThemeName) {
      return FootballTheme();
    } else if (GameThemeNames.matrix.name == gameThemeName) {
      return MatrixTheme();
    } else if (GameThemeNames.brownBg.name == gameThemeName) {
      return BrownBgTheme();
    } else if (GameThemeNames.yellowBg.name == gameThemeName) {
      return YellowBgTheme();
    } else if (GameThemeNames.inverted.name == gameThemeName) {
      return InvertedTheme();
    }
    return ClassicTheme();
  }
}
