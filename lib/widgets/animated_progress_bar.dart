import 'package:flutter/material.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return LinearProgressIndicator(
            value: value,
            minHeight: height,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          );
        },
      ),
    );
  }
}
