import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../data/learn_store.dart';
import '../models/language.dart';
import 'app_theme.dart';
import 'language_badge.dart';

/// Refined bottom sheet to choose the language to learn.
Future<void> showLanguagePicker(BuildContext context, LearnStore store) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final isDark = theme.brightness == Brightness.dark;

      return SafeArea(
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose a language',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your progress and streak are tracked independently for each language.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final language in Language.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LanguageOptionTile(
                        language: language,
                        isSelected: store.language == language,
                        onTap: () async {
                          await store.setLanguage(language);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final Language language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08)
        : (isDark ? AppTheme.darkSurface : AppTheme.lightSurface);

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : (isDark ? AppTheme.darkBorder : AppTheme.lightBorder);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: borderColor, width: isSelected ? 1.6 : 1),
          ),
          child: Row(
            children: [
              LanguageBadge(language: language, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      language.nativeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: PhosphorIcon(
                      PhosphorIconsBold.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                PhosphorIcon(
                  PhosphorIconsRegular.caretRight,
                  size: 20,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
