import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/content.dart';
import '../data/learn_store.dart';
import '../models/lesson_category.dart';
import '../widgets/app_theme.dart';
import '../widgets/circular_score_ring.dart';
import 'home_shell.dart';

/// "Progress" tab: overall mastery ring, topic breakdown,
/// quiz performance statistics, history log, and guarded progress reset.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.store});

  final LearnStore store;

  String _date(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  Future<void> _confirmReset(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          side: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const PhosphorIcon(
                PhosphorIconsRegular.warningCircle,
                color: AppTheme.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Reset all progress?',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Learned items, quiz history and your streak will be cleared for every language. This action cannot be undone.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.resetProgress();
    }
  }

  PhosphorIconData _iconForCategory(LessonCategory cat) {
    return switch (cat) {
      LessonCategory.vocabulary => PhosphorIconsBold.bookOpen,
      LessonCategory.phrases => PhosphorIconsBold.chatsCircle,
      LessonCategory.grammar => PhosphorIconsBold.bracketsCurly,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final language = store.language;
        final all = Content.forLanguage(language);
        final learned = store.learnedCountForLanguage;
        final overall = all.isEmpty ? 0.0 : (learned / all.length).clamp(0.0, 1.0);
        final results = store.results;

        final average = results.isEmpty
            ? 0
            : (results.map((r) => r.percent).reduce((a, b) => a + b) /
                    results.length)
                .round();
        final best = results.isEmpty
            ? 0
            : results.map((r) => r.percent).reduce((a, b) => a > b ? a : b);

        final cardBg = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
        final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        final bottomPadding = navBarClearance(context);

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
            children: [
              // ---- Header (Fixed spacing, no cramped title under app bar)
              Text(
                '${language.label} Mastery',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Track your memory retention, topic milestones, and quiz scores.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // ---- Overall Progress Hero Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131928) : const Color(0xFFEFF5FF),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(
                    color: AppTheme.brandPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
                    width: 1.2,
                  ),
                  boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
                ),
                child: Row(
                  children: [
                    CircularScoreRing(
                      progress: overall,
                      size: 84,
                      strokeWidth: 8,
                      color: AppTheme.brandPrimary,
                      centerText: '${(overall * 100).round()}%',
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$learned of ${all.length} learned',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            overall >= 1.0
                                ? 'All available items in this syllabus mastered!'
                                : '${all.length - learned} items remaining to unlock full fluency.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const PhosphorIcon(
                                PhosphorIconsFill.fire,
                                size: 16,
                                color: AppTheme.phrasesOrange,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${store.currentStreak} ${store.currentStreak == 1 ? 'day' : 'days'} streak',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.phrasesOrange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ---- Per Topic Breakdown
              Text(
                'Topic Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < LessonCategory.values.length; i++) ...[
                      Builder(
                        builder: (context) {
                          final cat = LessonCategory.values[i];
                          final items = Content.forCategory(language, cat);
                          final done = store.learnedAmong(items);
                          final catProgress =
                              items.isEmpty ? 0.0 : (done / items.length).clamp(0.0, 1.0);

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: cat.color.withValues(alpha: isDark ? 0.2 : 0.12),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 2),
                                    ),
                                    child: Center(
                                      child: PhosphorIcon(
                                        _iconForCategory(cat),
                                        size: 18,
                                        color: cat.color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cat.label,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '$done of ${items.length} mastered',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontSize: 11,
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                            fontFeatures: const [FontFeature.tabularFigures()],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${(catProgress * 100).round()}%',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cat.color,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.0, end: catProgress),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, val, _) {
                                    return LinearProgressIndicator(
                                      value: val,
                                      minHeight: 5,
                                      color: cat.color,
                                      backgroundColor: cat.color.withValues(alpha: isDark ? 0.14 : 0.10),
                                    );
                                  },
                                ),
                              ),
                              if (i < LessonCategory.values.length - 1)
                                const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ---- Quiz Performance (Three Stat Tiles)
              Text(
                'Quiz Statistics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricTile(
                    label: 'Taken',
                    value: '${results.length}',
                    icon: PhosphorIconsRegular.clipboardText,
                    iconColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  _MetricTile(
                    label: 'Average',
                    value: '$average%',
                    icon: PhosphorIconsRegular.chartBar,
                    iconColor: AppTheme.vocabularyTeal,
                  ),
                  const SizedBox(width: 10),
                  _MetricTile(
                    label: 'Best',
                    value: '$best%',
                    icon: PhosphorIconsFill.trophy,
                    iconColor: AppTheme.phrasesOrange,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ---- Quiz History Log
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Sessions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (results.isNotEmpty)
                    Text(
                      'Last ${results.length > 8 ? 8 : results.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (results.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        PhosphorIcon(
                          PhosphorIconsRegular.pencilCircle,
                          size: 36,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No quizzes completed yet.',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Take a 10-question quiz in the Practice tab to evaluate your score.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final r in results.take(8))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${r.languageLabel} · ${r.categoryLabel}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _date(r.date),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (r.percent >= 80
                                      ? AppTheme.success
                                      : r.percent >= 50
                                          ? theme.colorScheme.primary
                                          : AppTheme.error)
                                  .withValues(alpha: isDark ? 0.18 : 0.12),
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(
                                color: (r.percent >= 80
                                        ? AppTheme.success
                                        : r.percent >= 50
                                            ? theme.colorScheme.primary
                                            : AppTheme.error)
                                    .withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${r.score}/${r.total}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${r.percent}%',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: r.percent >= 80
                                        ? AppTheme.success
                                        : r.percent >= 50
                                            ? theme.colorScheme.primary
                                            : AppTheme.error,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 32),

              // ---- Clearly Separated Destructive "Reset Progress" Action
              Center(
                child: TextButton.icon(
                  onPressed: () => _confirmReset(context),
                  icon: const PhosphorIcon(
                    PhosphorIconsRegular.trash,
                    size: 18,
                    color: AppTheme.error,
                  ),
                  label: const Text(
                    'Reset All Progress',
                    style: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final PhosphorIconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
        ),
        child: Column(
          children: [
            PhosphorIcon(icon, size: 20, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
