import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/content.dart';
import '../data/learn_store.dart';
import '../models/language.dart';
import '../models/lesson_category.dart';
import '../models/lesson_item.dart';
import '../widgets/app_theme.dart';
import '../widgets/language_badge.dart';
import '../widgets/language_sheet.dart';
import '../widgets/stat_tile.dart';
import 'home_shell.dart';
import 'lesson_screen.dart';

/// "Learn" tab: refined greeting header, language switcher badge,
/// animated streak & progress stats, hero daily lesson card, and interactive topic paths.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});

  final LearnStore store;

  void _open(
    BuildContext context, {
    required String title,
    required List<LessonItem> items,
    bool isDaily = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          store: store,
          title: title,
          items: items,
          isDaily: isDaily,
        ),
      ),
    );
  }

  String _greetingFor(Language lang) {
    return switch (lang) {
      Language.spanish => '¡Hola! Ready to practice?',
      Language.french => 'Bonjour! Prêt à apprendre?',
      Language.german => 'Guten Tag! Bereit zu lernen?',
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
        final daily = store.dailyItems;
        final doneToday = store.dailyDoneToday;
        final streak = store.currentStreak;
        final bottomPadding = navBarClearance(context);

        return SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding),
            children: [
              // ---- Header: Greeting & Language Switcher
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LanguageBadge(language: language, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greetingFor(language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          language.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      onTap: () => showLanguagePicker(context, store),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          border: Border.all(
                            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PhosphorIcon(
                              PhosphorIconsRegular.translate,
                              size: 16,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Switch',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- Compact Stats Row (Streak + Learned Items)
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      icon: PhosphorIconsFill.fire,
                      iconColor: AppTheme.phrasesOrange,
                      targetValue: streak,
                      label: streak == 1 ? 'Day streak' : 'Days streak',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      icon: PhosphorIconsFill.checkCircle,
                      iconColor: AppTheme.vocabularyTeal,
                      targetValue: learned,
                      total: all.length,
                      label: 'Mastered',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- Hero Card: Daily Lesson
              _DailyHeroCard(
                isDailyDone: doneToday,
                itemsCount: daily.length,
                onStart: () => _open(
                  context,
                  title: 'Daily lesson',
                  items: daily,
                  isDaily: true,
                ),
              ),
              const SizedBox(height: 28),

              // ---- Topic Learning Paths
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Curated Topics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${LessonCategory.values.length} Paths',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < LessonCategory.values.length; i++)
                _TopicCard(
                  category: LessonCategory.values[i],
                  language: language,
                  store: store,
                  isLast: i == LessonCategory.values.length - 1,
                  onTap: (items) => _open(context, title: LessonCategory.values[i].label, items: items),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DailyHeroCard extends StatelessWidget {
  const _DailyHeroCard({
    required this.isDailyDone,
    required this.itemsCount,
    required this.onStart,
  });

  final bool isDailyDone;
  final int itemsCount;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF131A2A) : const Color(0xFFEFF5FF);
    final borderColor = isDark
        ? AppTheme.brandPrimary.withValues(alpha: 0.3)
        : AppTheme.brandPrimary.withValues(alpha: 0.25);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDailyDone
                      ? AppTheme.success.withValues(alpha: isDark ? 0.2 : 0.12)
                      : AppTheme.brandPrimary.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(
                      isDailyDone
                          ? PhosphorIconsFill.checkCircle
                          : PhosphorIconsFill.sparkle,
                      size: 14,
                      color: isDailyDone ? AppTheme.success : AppTheme.brandPrimary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isDailyDone ? 'COMPLETED TODAY' : 'DAILY FOCUS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDailyDone ? AppTheme.success : AppTheme.brandPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 5-dot visual indicator for the 5 daily items
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(itemsCount, (index) {
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDailyDone
                          ? AppTheme.success
                          : (isDark ? Colors.white.withValues(alpha: 0.25) : AppTheme.brandPrimary.withValues(alpha: 0.3)),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isDailyDone ? 'Daily Lesson Completed!' : 'Today’s Target Lesson',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isDailyDone
                ? 'You finished all 5 cards today. Revisit them anytime to refresh your memory.'
                : '$itemsCount essential expressions picked for your daily momentum.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: isDailyDone
                ? OutlinedButton.icon(
                    onPressed: onStart,
                    icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise, size: 18),
                    label: const Text('Review Lesson Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: onStart,
                    icon: const PhosphorIcon(PhosphorIconsFill.play, size: 18),
                    label: const Text('Start Daily Lesson'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.brandPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopicCard extends StatefulWidget {
  const _TopicCard({
    required this.category,
    required this.language,
    required this.store,
    required this.onTap,
    this.isLast = false,
  });

  final LessonCategory category;
  final Language language;
  final LearnStore store;
  final void Function(List<LessonItem>) onTap;
  final bool isLast;

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _pressed = false;

  PhosphorIconData _iconForCategory(LessonCategory cat) {
    return switch (cat) {
      LessonCategory.vocabulary => PhosphorIconsBold.bookOpen,
      LessonCategory.phrases => PhosphorIconsBold.chatsCircle,
      LessonCategory.grammar => PhosphorIconsBold.bracketsCurly,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = Content.forCategory(widget.language, widget.category);
    final learned = widget.store.learnedAmong(items);
    final progress = items.isEmpty ? 0.0 : (learned / items.length).clamp(0.0, 1.0);

    final cardBg = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final catColor = widget.category.color;

    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 12),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              onHighlightChanged: (val) => setState(() => _pressed = val),
              onTap: () => widget.onTap(items),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: isDark ? 0.16 : 0.12),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: catColor.withValues(alpha: isDark ? 0.35 : 0.25),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: PhosphorIcon(
                              _iconForCategory(widget.category),
                              color: catColor,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.category.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.category.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        PhosphorIcon(
                          PhosphorIconsRegular.caretRight,
                          size: 18,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$learned of ${items.length} learned',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: catColor,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) {
                          return LinearProgressIndicator(
                            value: val,
                            minHeight: 5,
                            color: catColor,
                            backgroundColor: catColor.withValues(alpha: isDark ? 0.14 : 0.10),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
