import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/content.dart';
import '../data/learn_store.dart';
import '../models/lesson_category.dart';
import '../widgets/app_theme.dart';
import 'home_shell.dart';
import 'quiz_screen.dart';

/// "Practice" tab: topic selection as large interactive cards,
/// prominent start quiz action, and best-score achievement card.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.store});

  final LearnStore store;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  LessonCategory? _category; // null = all topics

  void _start() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(store: widget.store, category: _category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final language = widget.store.language;
        final results = widget.store.results;

        final best = results.isEmpty
            ? null
            : results.map((r) => r.percent).reduce((a, b) => a > b ? a : b);

        final totalAllItems = Content.forLanguage(language).length;
        final bottomPadding = navBarClearance(context);

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
            children: [
              // ---- Header
              Text(
                '${language.label} Quiz',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${QuizScreen.questionCount} multiple-choice questions to test your comprehension and recall speed.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // ---- Topic Selector (Large Rich Tiles)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Focus Topic',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    _category == null ? 'All Topics' : _category!.label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tile 1: All Topics
              _TopicSelectTile(
                title: 'All Topics',
                subtitle: 'Mixed vocabulary, expressions, and grammar',
                countLabel: '$totalAllItems items',
                icon: PhosphorIconsBold.cards,
                accentColor: theme.colorScheme.primary,
                isSelected: _category == null,
                onTap: () => setState(() => _category = null),
              ),
              const SizedBox(height: 10),

              // Tiles 2-4: Each LessonCategory
              for (final cat in LessonCategory.values) ...[
                Builder(
                  builder: (context) {
                    final count = Content.forCategory(language, cat).length;
                    final icon = switch (cat) {
                      LessonCategory.vocabulary => PhosphorIconsBold.bookOpen,
                      LessonCategory.phrases => PhosphorIconsBold.chatsCircle,
                      LessonCategory.grammar => PhosphorIconsBold.bracketsCurly,
                    };

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TopicSelectTile(
                        title: cat.label,
                        subtitle: cat.description,
                        countLabel: '$count items',
                        icon: icon,
                        accentColor: cat.color,
                        isSelected: _category == cat,
                        onTap: () => setState(() => _category = cat),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 20),

              // ---- Prominent Start Quiz Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _start,
                  icon: const PhosphorIcon(PhosphorIconsFill.play, size: 20),
                  label: const Text('Start 10-Question Quiz'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ---- Best Score Summary Card
              _BestScoreCard(bestScore: best, totalQuizzes: results.length),
            ],
          ),
        );
      },
    );
  }
}

class _TopicSelectTile extends StatelessWidget {
  const _TopicSelectTile({
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String countLabel;
  final PhosphorIconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isSelected
        ? accentColor.withValues(alpha: isDark ? 0.16 : 0.08)
        : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface);

    final borderColor = isSelected
        ? accentColor
        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: borderColor, width: isSelected ? 1.8 : 1),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : (isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Center(
                  child: PhosphorIcon(
                    icon,
                    color: accentColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkSurfaceHighlight : AppTheme.lightSurfaceHighlight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            countLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? accentColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? accentColor : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: PhosphorIcon(
                          PhosphorIconsBold.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BestScoreCard extends StatelessWidget {
  const _BestScoreCard({required this.bestScore, required this.totalQuizzes});

  final int? bestScore;
  final int totalQuizzes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.phrasesOrange.withValues(alpha: isDark ? 0.16 : 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Center(
              child: PhosphorIcon(
                PhosphorIconsFill.trophy,
                color: AppTheme.phrasesOrange,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bestScore == null
                      ? 'No Quizzes Completed Yet'
                      : 'Best Score: $bestScore%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bestScore == null
                      ? 'Take your first quiz to calibrate your knowledge.'
                      : '$totalQuizzes quiz${totalQuizzes == 1 ? '' : 'zes'} taken so far.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
