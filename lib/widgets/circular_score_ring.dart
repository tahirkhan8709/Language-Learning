import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';

/// Animated circular progress/score ring drawn with CustomPainter.
/// Features rounded stroke caps, smooth easing, and tabular figures.
class CircularScoreRing extends StatelessWidget {
  const CircularScoreRing({
    super.key,
    required this.progress, // 0.0 to 1.0
    this.size = 110,
    this.strokeWidth = 10,
    this.color,
    this.centerText,
    this.centerSubtitle,
    this.duration = const Duration(milliseconds: 900),
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? color;
  final String? centerText;
  final String? centerSubtitle;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ringColor = color ?? theme.colorScheme.primary;
    final trackColor = isDark
        ? ringColor.withValues(alpha: 0.15)
        : ringColor.withValues(alpha: 0.12);

    final clampedProgress = progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: clampedProgress),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, animatedValue, child) {
          final displayPercent = (animatedValue * 100).round();
          final text = centerText ?? '$displayPercent%';

          return CustomPaint(
            painter: _RingPainter(
              progress: animatedValue,
              strokeWidth: strokeWidth,
              ringColor: ringColor,
              trackColor: trackColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (centerSubtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      centerSubtitle!,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: size * 0.10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.ringColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color ringColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Active arc
    final arcPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.trackColor != trackColor;
  }
}
