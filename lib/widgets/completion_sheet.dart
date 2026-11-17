import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_theme.dart';

/// Shows a celebratory but classy completion bottom sheet
/// with animated geometric confetti particles drawn via CustomPainter.
Future<void> showLessonCompletionSheet(
  BuildContext context, {
  required bool isDaily,
  required int streak,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CompletionSheetContent(isDaily: isDaily, streak: streak),
  );
}

class _CompletionSheetContent extends StatefulWidget {
  const _CompletionSheetContent({
    required this.isDaily,
    required this.streak,
  });

  final bool isDaily;
  final int streak;

  @override
  State<_CompletionSheetContent> createState() => _CompletionSheetContentState();
}

class _CompletionSheetContentState extends State<_CompletionSheetContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurface;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => CustomPaint(
                      painter: _ConfettiPainter(progress: _controller.value),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isDaily
                            ? AppTheme.phrasesOrange.withValues(alpha: 0.16)
                            : AppTheme.success.withValues(alpha: 0.16),
                        border: Border.all(
                          color: widget.isDaily
                              ? AppTheme.phrasesOrange.withValues(alpha: 0.35)
                              : AppTheme.success.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: PhosphorIcon(
                          widget.isDaily
                              ? PhosphorIconsFill.fire
                              : PhosphorIconsFill.checkCircle,
                          size: 38,
                          color: widget.isDaily
                              ? AppTheme.phrasesOrange
                              : AppTheme.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.isDaily ? 'Daily Goal Achieved!' : 'Lesson Complete!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.isDaily
                          ? 'You completed today’s 5 target items. Come back tomorrow to keep your momentum going!'
                          : 'Great focus! Every session strengthens your vocabulary and recall.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                    if (widget.isDaily && widget.streak > 0) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.phrasesOrange.withValues(alpha: isDark ? 0.12 : 0.08),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          border: Border.all(
                            color: AppTheme.phrasesOrange.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PhosphorIcon(
                              PhosphorIconsFill.fire,
                              size: 18,
                              color: AppTheme.phrasesOrange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.streak} Day Streak!',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppTheme.phrasesOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    required this.isSquare,
  });

  final double angle;
  final double speed;
  final double size;
  final Color color;
  final bool isSquare;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress}) {
    final rng = math.Random(42);
    final colors = [
      AppTheme.brandPrimary,
      AppTheme.vocabularyTeal,
      AppTheme.phrasesOrange,
      AppTheme.grammarIndigo,
      const Color(0xFFFBBF24),
    ];
    particles = List.generate(24, (i) {
      return _ConfettiParticle(
        angle: rng.nextDouble() * 2 * math.pi,
        speed: 60 + rng.nextDouble() * 110,
        size: 4 + rng.nextDouble() * 5,
        color: colors[i % colors.length],
        isSquare: i % 2 == 0,
      );
    });
  }

  final double progress;
  late final List<_ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = Offset(size.width / 2, 70);

    for (final p in particles) {
      final distance = p.speed * progress;
      final x = center.dx + math.cos(p.angle) * distance;
      final y = center.dy + math.sin(p.angle) * distance + (progress * progress * 40);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      if (p.isSquare) {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * 4);
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(x, y), p.size / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
