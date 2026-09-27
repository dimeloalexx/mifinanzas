import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final IconData icon;
  final double size;
  final double strokeWidth;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    required this.icon,
    this.size = 52,
    this.strokeWidth = 5,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: strokeWidth,
                  color: color.withValues(alpha: 0.15),
                ),
              ),
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Icon(icon, color: color, size: size * 0.4),
            ],
          );
        },
      ),
    );
  }
}
