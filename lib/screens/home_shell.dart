import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/learn_store.dart';
import '../widgets/app_theme.dart';
import 'home_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';

/// Modern bottom navigation shell between Learn, Practice, and Progress.
/// Features a floating pill navigation bar with a sliding raised circle
/// cutout for the active destination.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});

  final LearnStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SizedBox.expand(
            child: IndexedStack(
              index: _index,
              children: [
                HomeScreen(store: widget.store),
                PracticeScreen(store: widget.store),
                ProgressScreen(store: widget.store),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _index,
        onTap: (index) {
          if (_index != index) {
            Feedback.forTap(context);
            setState(() => _index = index);
          }
        },
      ),
    );
  }
}

/// The single source of truth for the bottom clearance of scrollables
/// displayed on the tabs of [HomeShell].
///
/// Ensures the bottom-most item sits exactly 24px above the raised circle
/// of the floating pill navigation bar at full scroll extent:
/// bar height (64) + raised-circle overhang (20) + bottom margin (12)
/// + desired scroll gap (24) + device safe-area bottom = 120 + safeAreaBottom.
double navBarClearance(BuildContext context) {
  return _FloatingNavBar.baseClearance + MediaQuery.viewPaddingOf(context).bottom;
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.iconInactive,
    required this.iconActive,
  });

  final String label;
  final PhosphorIconData iconInactive;
  final PhosphorIconData iconActive;
}

const _navItems = [
  _NavItemData(
    label: 'Learn',
    iconInactive: PhosphorIconsRegular.graduationCap,
    iconActive: PhosphorIconsFill.graduationCap,
  ),
  _NavItemData(
    label: 'Practice',
    iconInactive: PhosphorIconsRegular.lightning,
    iconActive: PhosphorIconsFill.lightning,
  ),
  _NavItemData(
    label: 'Progress',
    iconInactive: PhosphorIconsRegular.chartLineUp,
    iconActive: PhosphorIconsFill.chartLineUp,
  ),
];

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double barHeight = 64.0;
  static const double circleDiameter = 56.0;
  static const double circleOverhang = 20.0;
  static const double ringThickness = 4.0;
  static const double cutoutDiameter = circleDiameter + (ringThickness * 2); // 64.0
  static const double topClearance = 24.0;
  static const double bottomMargin = 12.0;
  static const double contentGap = 24.0;

  /// Combined constant clearance before adding device safe-area bottom: 120.0.
  static const double baseClearance = barHeight + circleOverhang + bottomMargin + contentGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    final pageBg = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final navBg = isDark ? AppTheme.darkSurface : Colors.white;
    final navBorder = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final navShadow = isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight;

    final totalHeight = topClearance + barHeight + bottomMargin + safeBottom;

    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = math.min(constraints.maxWidth, 640.0);
          final barWidth = maxW - 32.0;
          final barLeft = (constraints.maxWidth - barWidth) / 2.0;
          final slotWidth = barWidth / _navItems.length;

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: currentIndex.toDouble(),
              end: currentIndex.toDouble(),
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, animIndex, _) {
              final activeCenterX = barLeft + (animIndex + 0.5) * slotWidth;
              final cutoutLeft = activeCenterX - (cutoutDiameter / 2.0);
              final circleLeft = activeCenterX - (circleDiameter / 2.0);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. The Floating Pill Bar Surface
                  Positioned(
                    left: barLeft,
                    top: topClearance,
                    width: barWidth,
                    height: barHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: navBg,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: navBorder, width: 1),
                        boxShadow: navShadow,
                      ),
                      child: Row(
                        children: List.generate(_navItems.length, (i) {
                          final isSelected = currentIndex == i;

                          return Expanded(
                            child: Semantics(
                              label: '${_navItems[i].label} tab',
                              selected: isSelected,
                              button: true,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(32),
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () => onTap(i),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: isSelected ? 0.0 : 1.0,
                                          child: PhosphorIcon(
                                            _navItems[i].iconInactive,
                                            size: 24,
                                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        AnimatedDefaultTextStyle(
                                          duration: const Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontFamily,
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                                            letterSpacing: 0.1,
                                          ),
                                          child: Text(_navItems[i].label),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // 2. The Cutout Ring (4px in page background color around the 56px circle)
                  Positioned(
                    left: cutoutLeft,
                    top: (topClearance - circleOverhang) - ringThickness, // 24 - 20 - 4 = 0.0
                    width: cutoutDiameter,
                    height: cutoutDiameter,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          color: pageBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: navBorder,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. The Raised Circle (56px) with Accent Gradient & Active Icon
                  Positioned(
                    left: circleLeft,
                    top: topClearance - circleOverhang, // 24 - 20 = 4.0
                    width: circleDiameter,
                    height: circleDiameter,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? const [Color(0xFF60A5FA), Color(0xFF2563EB)]
                                : const [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.40 : 0.32),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.82, end: 1.0).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: PhosphorIcon(
                              _navItems[currentIndex].iconActive,
                              key: ValueKey<int>(currentIndex),
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
