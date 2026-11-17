import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';

/// Segmented step progress bar (one capsule per step),
/// with smooth fill transitions between steps.
class SegmentedProgressBar extends StatelessWidget {
  const SegmentedProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.height = 6.0,
    this.spacing = 5.0,
  });

  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final double height;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = activeColor ?? theme.colorScheme.primary;
    final inactive = isDark
        ? AppTheme.darkSurfaceHighlight
        : AppTheme.lightSurfaceHighlight;

    if (totalSteps <= 0) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isCompleted = index < currentStep;
          final isCurrent = index == currentStep;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(height / 2),
                  color: (isCompleted || isCurrent) ? color : inactive,
                  border: isCurrent
                      ? Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.3) : color.withValues(alpha: 0.4),
                          width: 1,
                        )
                      : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
