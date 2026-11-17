import 'package:material_ui/material_ui.dart';

import '../models/language.dart';

/// Tasteful custom badge drawn with geometric shapes in its own color scheme
/// (strictly no flags, no emoji).
class LanguageBadge extends StatelessWidget {
  const LanguageBadge({
    super.key,
    required this.language,
    this.size = 40,
    this.showBorder = true,
  });

  final Language language;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final (baseColor, accentColor, shapeType) = switch (language) {
      Language.spanish => (
          const Color(0xFFE11D48), // Warm Iberian Crimson
          const Color(0xFFFBBF24), // Spanish Sun Gold
          _BadgeShape.diamond,
        ),
      Language.french => (
          const Color(0xFF2563EB), // Ultramarine Blue
          const Color(0xFF38BDF8), // Cyan Breeze
          _BadgeShape.hexagon,
        ),
      Language.german => (
          const Color(0xFFD97706), // Imperial Amber Gold
          const Color(0xFF1E293B), // Obsidian Slate
          _BadgeShape.shield,
        ),
    };

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BadgePainter(
          baseColor: baseColor,
          accentColor: accentColor,
          shape: shapeType,
          showBorder: showBorder,
        ),
        child: Center(
          child: Text(
            language.code.toUpperCase(),
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: size * 0.36,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

enum _BadgeShape { diamond, hexagon, shield }

class _BadgePainter extends CustomPainter {
  const _BadgePainter({
    required this.baseColor,
    required this.accentColor,
    required this.shape,
    required this.showBorder,
  });

  final Color baseColor;
  final Color accentColor;
  final _BadgeShape shape;
  final bool showBorder;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;

    // Outer background with smooth gradient
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColor, baseColor.withValues(alpha: 0.85)],
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.width * 0.28));
    canvas.drawRRect(rrect, bgPaint);

    // Geometric micro-accent in the background
    final accentPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;

    switch (shape) {
      case _BadgeShape.diamond:
        // Elegant rotated square in top-right
        final path = Path()
          ..moveTo(center.dx, 4)
          ..lineTo(size.width - 4, center.dy)
          ..lineTo(center.dx, size.height - 4)
          ..lineTo(4, center.dy)
          ..close();
        canvas.drawPath(path, accentPaint);
      case _BadgeShape.hexagon:
        // Dual concentric subtle circles
        canvas.drawCircle(center, radius * 0.76, accentPaint);
        canvas.drawCircle(
          center,
          radius * 0.52,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.12)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      case _BadgeShape.shield:
        // Geometric split chevron
        final path = Path()
          ..moveTo(rect.left + 4, rect.top + 4)
          ..lineTo(rect.right - 4, rect.top + 4)
          ..lineTo(center.dx, rect.bottom - 4)
          ..close();
        canvas.drawPath(path, accentPaint);
    }

    // High quality 1px outline border
    if (showBorder) {
      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(rrect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BadgePainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.shape != shape ||
        oldDelegate.showBorder != showBorder;
  }
}
