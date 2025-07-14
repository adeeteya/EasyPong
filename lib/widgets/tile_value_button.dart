import 'package:easy_pong/notifiers/settings_notifier.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TileValueButton extends ConsumerWidget {
  final String titleText;
  final String valueText;
  final VoidCallback onTap;
  final double width;
  final double height;
  final Color? tileBackgroundColor;
  const TileValueButton({
    super.key,
    required this.titleText,
    required this.valueText,
    required this.onTap,
    this.width = 350,
    this.height = 60,
    this.tileBackgroundColor,
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
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            children: [
              const SizedBox(width: 2),
              Text(
                titleText,
                textAlign: TextAlign.center,
                style:
                    (width <= 250)
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                    valueText,
                    textAlign: TextAlign.center,
                    style:
                        (width <= 250)
                            ? Theme.of(context).textTheme.bodySmall
                            : Theme.of(context).textTheme.titleMedium,
                  )
                  .animate(key: ValueKey(valueText))
                  .fade(duration: 300.ms)
                  .slideX(duration: 300.ms, begin: -0.5, end: 0),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ),
    );
  }
}
