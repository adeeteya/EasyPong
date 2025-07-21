import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TileButton extends ConsumerWidget {
  final String titleText;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Color? tileBackgroundColor;
  final Color borderColor;
  const TileButton({
    super.key,
    required this.titleText,
    required this.onTap,
    this.width = 350,
    this.height = 60,
    this.tileBackgroundColor,
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: InkWell(
        onTap: () async {
          if (ref.read(settingsProvider).isSfxEnabled) {
            await FlameAudio.play("ping.mp3");
          }
          onTap();
        },
        child: Ink(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: tileBackgroundColor,
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: Text(
              titleText,
              textAlign: TextAlign.center,
              style: (width <= 250)
                  ? Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: borderColor)
                  : Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: borderColor),
            ),
          ),
        ),
      ),
    );
  }
}
