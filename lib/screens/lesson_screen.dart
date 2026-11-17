import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/learn_store.dart';
import '../models/lesson_item.dart';
import '../services/speaker.dart';
import '../widgets/app_theme.dart';
import '../widgets/completion_sheet.dart';
import '../widgets/segmented_progress_bar.dart';

/// Flashcard lesson screen with a real 3D perspective flip,
/// segmented progress, interactive pronunciation & pulsing audio player.
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.store,
    required this.title,
    required this.items,
    this.isDaily = false,
  });

  final LearnStore store;
  final String title;
  final List<LessonItem> items;
  final bool isDaily;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with TickerProviderStateMixin {
  int _index = 0;

  // 3D Flip animation
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  // Audio pulsing animation
  late final AnimationController _pulseController;
  bool _speaking = false;

  LessonItem get _item => widget.items[_index];
  bool get _isLast => _index == widget.items.length - 1;
  bool get _isFlipped => _flipController.value >= 0.5;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_flipController.isAnimating) return;
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _go(int delta) {
    if (_flipController.value > 0) {
      _flipController.reverse();
    }
    setState(() {
      _index += delta;
    });
  }

  Future<void> _speak() async {
    setState(() => _speaking = true);
    _pulseController.repeat(reverse: true);
    final ok = await Speaker.speak(_item.target, _item.language.ttsLocale);
    if (mounted) {
      setState(() => _speaking = false);
      _pulseController.stop();
      _pulseController.reset();
      if (!ok) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Audio is not available on this device.'),
            ),
          );
      }
    }
  }

  Future<void> _finish() async {
    final navigator = Navigator.of(context);
    if (widget.isDaily) {
      await widget.store.completeDaily();
    }
    if (!mounted) return;

    // Show classy completion sheet
    await showLessonCompletionSheet(
      context,
      isDaily: widget.isDaily,
      streak: widget.store.currentStreak,
    );

    if (mounted) {
      navigator.pop();
    }
  }

  Future<void> _markKnown() async {
    await widget.store.setLearned(_item.id, true);
    if (!mounted) return;
    if (_isLast) {
      await _finish();
    } else {
      _go(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final learned = widget.store.isLearned(_item.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (learned)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.success.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PhosphorIcon(
                        PhosphorIconsFill.checkCircle,
                        size: 14,
                        color: AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Learned',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.success,
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
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                children: [
                  // ---- Step Counter & Segmented Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card ${_index + 1} of ${widget.items.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                          fontWeight: FontWeight.w700,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        '${((_index + 1) / widget.items.length * 100).round()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedProgressBar(
                    totalSteps: widget.items.length,
                    currentStep: _index,
                    activeColor: _item.category.color,
                  ),
                  const SizedBox(height: 20),

                  // ---- 3D Perspective Card Area
                  Expanded(
                    child: GestureDetector(
                      onTap: _flip,
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, _) {
                          final angle = _flipAnimation.value * math.pi;
                          final isBackVisible = _flipAnimation.value >= 0.5;

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.0012)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: isBackVisible
                                ? Transform(
                                    transform: Matrix4.identity()..rotateY(math.pi),
                                    alignment: Alignment.center,
                                    child: _CardBack(
                                      key: ValueKey('${_item.id}-back'),
                                      item: _item,
                                      learned: learned,
                                      isSpeaking: _speaking,
                                      pulseValue: _pulseController.value,
                                      onSpeak: _speak,
                                    ),
                                  )
                                : _CardFront(
                                    key: ValueKey('${_item.id}-front'),
                                    item: _item,
                                    learned: learned,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- Action Buttons: Show Translation + I Know This
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, _) {
                      final flipped = _isFlipped;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _flip,
                                  icon: PhosphorIcon(
                                    flipped
                                        ? PhosphorIconsRegular.arrowCounterClockwise
                                        : PhosphorIconsRegular.arrowsClockwise,
                                    size: 18,
                                  ),
                                  label: Text(
                                    flipped ? 'Show English' : 'Show Meaning',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _markKnown,
                                  icon: const PhosphorIcon(
                                    PhosphorIconsBold.check,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _isLast ? 'Finish' : 'I Know This',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.success,
                                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _index > 0 ? () => _go(-1) : null,
                                icon: const PhosphorIcon(
                                  PhosphorIconsRegular.arrowLeft,
                                  size: 16,
                                ),
                                label: const Text('Previous'),
                              ),
                              TextButton.icon(
                                onPressed: _isLast ? _finish : () => _go(1),
                                icon: PhosphorIcon(
                                  _isLast
                                      ? PhosphorIconsFill.flagBanner
                                      : PhosphorIconsRegular.arrowRight,
                                  size: 16,
                                ),
                                label: Text(_isLast ? 'Complete' : 'Next Card'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({super.key, required this.item, required this.learned});

  final LessonItem item;
  final bool learned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: item.category.color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  'ENGLISH PROMPT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: item.category.color,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              PhosphorIcon(
                PhosphorIconsRegular.arrowsClockwise,
                size: 18,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.english,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceElevated : AppTheme.lightSurfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhosphorIcon(
                          PhosphorIconsRegular.handTap,
                          size: 16,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Tap to reveal in ${item.language.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({
    super.key,
    required this.item,
    required this.learned,
    required this.isSpeaking,
    required this.pulseValue,
    required this.onSpeak,
  });

  final LessonItem item;
  final bool learned;
  final bool isSpeaking;
  final double pulseValue;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF141926) : const Color(0xFFF0F5FF);
    final borderColor = isDark
        ? AppTheme.brandPrimary.withValues(alpha: 0.35)
        : AppTheme.brandPrimary.withValues(alpha: 0.25);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: borderColor, width: 1.4),
        boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.brandPrimary.withValues(alpha: isDark ? 0.25 : 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  item.language.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.brandPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              PhosphorIcon(
                PhosphorIconsRegular.arrowsClockwise,
                size: 18,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Target translation
                    Text(
                      item.target,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? Colors.white : AppTheme.brandPrimaryDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pronunciation pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurfaceHighlight : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Say it: ${item.phonetic}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Circular listen button with pulsing wave ring
                    Semantics(
                      label: 'Listen to pronunciation',
                      button: true,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isSpeaking)
                            Container(
                              width: 58 + (pulseValue * 16),
                              height: 58 + (pulseValue * 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.brandPrimary.withValues(
                                  alpha: (1.0 - pulseValue) * 0.4,
                                ),
                              ),
                            ),
                          Material(
                            color: AppTheme.brandPrimary,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onSpeak,
                              child: Container(
                                width: 54,
                                height: 54,
                                alignment: Alignment.center,
                                child: const PhosphorIcon(
                                  PhosphorIconsFill.speakerHigh,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Usage / grammar tip note box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurfaceElevated : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PhosphorIcon(
                            PhosphorIconsRegular.lightbulb,
                            size: 18,
                            color: AppTheme.phrasesOrange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.note,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.4,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
