import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/content.dart';
import '../data/learn_store.dart';
import '../models/lesson_category.dart';
import '../models/lesson_item.dart';
import '../models/quiz_result.dart';
import '../services/speaker.dart';
import '../widgets/app_theme.dart';
import '../widgets/circular_score_ring.dart';
import '../widgets/segmented_progress_bar.dart';

class _Question {
  const _Question({
    required this.item,
    required this.toTarget,
    required this.options,
    required this.correctIndex,
  });

  final LessonItem item;
  final bool toTarget;
  final List<String> options;
  final int correctIndex;
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.store, this.category});

  final LearnStore store;
  final LessonCategory? category;

  static const int questionCount = 10;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late List<_Question> _questions = _buildQuestions();
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _finished = false;

  // Shake animation on wrong answer
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  List<_Question> _buildQuestions() {
    final rng = math.Random();
    final language = widget.store.language;
    final pool = widget.category == null
        ? Content.forLanguage(language)
        : Content.forCategory(language, widget.category!);

    final picked = ([...pool]..shuffle(rng)).take(QuizScreen.questionCount);

    return picked.map((item) {
      final toTarget = rng.nextBool();
      String textOf(LessonItem i) => toTarget ? i.target : i.english;
      final correct = textOf(item);

      final distractors =
          ([...Content.forCategory(language, item.category)]..shuffle(rng))
              .where((i) => i.id != item.id)
              .map(textOf)
              .where((t) => t != correct)
              .toSet()
              .take(3)
              .toList();

      final options = [correct, ...distractors]..shuffle(rng);
      return _Question(
        item: item,
        toTarget: toTarget,
        options: options,
        correctIndex: options.indexOf(correct),
      );
    }).toList();
  }

  bool get _answered => _selected != null;
  bool get _isLast => _index == _questions.length - 1;

  void _choose(int i) {
    if (_answered) return;
    final correct = i == _questions[_index].correctIndex;
    setState(() {
      _selected = i;
      if (correct) {
        _score++;
      } else {
        _shakeController.forward(from: 0.0);
      }
    });
  }

  void _next() {
    if (_isLast) {
      widget.store.addQuizResult(
        QuizResult(
          languageLabel: widget.store.language.label,
          categoryLabel: widget.category?.label ?? 'All topics',
          score: _score,
          total: _questions.length,
          date: DateTime.now(),
        ),
      );
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  void _restart() {
    setState(() {
      _questions = _buildQuestions();
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  Future<void> _speak(LessonItem item) async {
    final ok = await Speaker.speak(item.target, item.language.ttsLocale);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Audio is not available on this device.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _finished
              ? 'Quiz Result'
              : 'Question ${_index + 1} of ${_questions.length}',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _finished ? _buildResult(context) : _buildQuestion(context),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final q = _questions[_index];
    final language = widget.store.language;

    final questionBg = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final questionBorder = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        // ---- Segmented Progress Bar
        Row(
          children: [
            Expanded(
              child: Text(
                '${widget.category?.label ?? 'All Topics'} · ${_index + 1}/${_questions.length}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Score: $_score',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SegmentedProgressBar(
          totalSteps: _questions.length,
          currentStep: _index,
        ),
        const SizedBox(height: 20),

        // ---- Question Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: questionBg,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: questionBorder, width: 1.2),
            boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  q.toTarget
                      ? 'TRANSLATE TO ${language.label.toUpperCase()}'
                      : 'WHAT DOES THIS MEAN IN ENGLISH?',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (q.toTarget)
                Text(
                  q.item.english,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        q.item.target,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Listen to pronunciation',
                      onPressed: () => _speak(q.item),
                      icon: PhosphorIcon(
                        PhosphorIconsFill.speakerHigh,
                        color: theme.colorScheme.primary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // ---- Answer Options with Letter Badges (A, B, C, D)
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final offset = math.sin(_shakeController.value * math.pi * 4) *
                8 *
                (1.0 - _shakeController.value);
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: Column(
            children: [
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _QuizOptionTile(
                    index: i,
                    text: q.options[i],
                    state: _stateFor(q, i),
                    onTap: () => _choose(i),
                  ),
                ),
            ],
          ),
        ),

        // ---- Slide-in Feedback Panel & Next Button
        if (_answered) ...[
          const SizedBox(height: 8),
          _FeedbackPanel(
            correct: _selected == q.correctIndex,
            item: q.item,
            language: language.label,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _next,
              child: Text(_isLast ? 'See Quiz Result' : 'Next Question'),
            ),
          ),
        ],
      ],
    );
  }

  _OptionState _stateFor(_Question q, int i) {
    if (!_answered) return _OptionState.idle;
    if (i == q.correctIndex) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  Widget _buildResult(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final total = _questions.length;
    final percent = total == 0 ? 0 : ((_score / total) * 100).round();

    final (headline, message, ringColor) = percent >= 80
        ? (
            'Outstanding Performance!',
            'You mastered this session with flying colors. Keep up this brilliant momentum!',
            AppTheme.success,
          )
        : percent >= 50
            ? (
                'Great Job!',
                'You have a solid foundation. A quick review of the missed cards will make it stick forever.',
                AppTheme.brandPrimary,
              )
            : (
                'Keep Practicing!',
                'Learning a language is all about spaced repetition. Review the flashcards and try again!',
                AppTheme.phrasesOrange,
              );

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const SizedBox(height: 20),
        Center(
          child: CircularScoreRing(
            progress: percent / 100,
            size: 140,
            strokeWidth: 12,
            color: ringColor,
            centerText: '$percent%',
            centerSubtitle: '$_score / $total correct',
          ),
        ),
        const SizedBox(height: 28),
        Text(
          headline,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _restart,
            icon: const PhosphorIcon(PhosphorIconsRegular.arrowClockwise, size: 18),
            label: const Text('Try Again'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _QuizOptionTile extends StatelessWidget {
  const _QuizOptionTile({
    required this.index,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final int index;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  static const _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color background;
    Color border;
    Color letterBg;
    Color letterColor;
    PhosphorIconData? trailingIcon;
    Color? iconColor;

    switch (state) {
      case _OptionState.correct:
        background = AppTheme.success.withValues(alpha: isDark ? 0.18 : 0.12);
        border = AppTheme.success;
        letterBg = AppTheme.success;
        letterColor = Colors.white;
        trailingIcon = PhosphorIconsBold.check;
        iconColor = AppTheme.success;
      case _OptionState.wrong:
        background = AppTheme.error.withValues(alpha: isDark ? 0.18 : 0.12);
        border = AppTheme.error;
        letterBg = AppTheme.error;
        letterColor = Colors.white;
        trailingIcon = PhosphorIconsBold.x;
        iconColor = AppTheme.error;
      case _OptionState.dimmed:
        background = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
        border = isDark ? AppTheme.darkBorderSubtle : AppTheme.lightBorderSubtle;
        letterBg = isDark ? AppTheme.darkSurfaceHighlight : AppTheme.lightSurfaceHighlight;
        letterColor = isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted;
      case _OptionState.idle:
        background = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
        border = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        letterBg = isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated;
        letterColor = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    }

    final letter = index < _letters.length ? _letters[index] : '${index + 1}';

    return Opacity(
      opacity: state == _OptionState.dimmed ? 0.45 : 1.0,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: state == _OptionState.idle ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: border, width: state == _OptionState.idle ? 1 : 1.6),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: letterBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 4),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: letterColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  PhosphorIcon(trailingIcon, size: 20, color: iconColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackPanel extends StatelessWidget {
  const _FeedbackPanel({
    required this.correct,
    required this.item,
    required this.language,
  });

  final bool correct;
  final LessonItem item;
  final String language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final feedbackColor = correct ? AppTheme.success : AppTheme.error;
    final bgColor = feedbackColor.withValues(alpha: isDark ? 0.14 : 0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: feedbackColor.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PhosphorIcon(
                correct ? PhosphorIconsFill.checkCircle : PhosphorIconsFill.xCircle,
                size: 20,
                color: feedbackColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  correct ? 'Correct! Excellent recall.' : 'Not quite right.',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: feedbackColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.english}  ⇄  ${item.target}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Say it: ${item.phonetic}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
