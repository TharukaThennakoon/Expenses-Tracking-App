import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shown when there are no expenses this month and no filters are applied.
class EmptyHistoryView extends StatelessWidget {
  const EmptyHistoryView({super.key, required this.onAddExpense});

  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
        child: Column(
          children: [
            const _ReceiptIllustration(),
            const SizedBox(height: 28),
            const Text(
              'No expenses yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first expense and it will show up here, grouped by '
              'day with a running monthly total.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 16,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: onAddExpense,
                style: FilledButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.add_rounded, color: AppColors.accent),
                label: const Text('Add expense'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptIllustration extends StatelessWidget {
  const _ReceiptIllustration();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 140,
        height: 128,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: CircleAvatar(
                radius: 64,
                backgroundColor: context.colors.illustrationBackground,
              ),
            ),
            Positioned(
              left: 28,
              top: 4,
              child: CustomPaint(
                size: const Size(72, 100),
                painter: _ReceiptPainter(
                  paper: context.colors.surface,
                  ink: context.colors.primaryText,
                  line: context.colors.skeleton,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 12,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.primary, width: 2.5),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 30,
                  color: context.colors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A paper receipt with a zig-zag torn bottom edge and a few text lines.
class _ReceiptPainter extends CustomPainter {
  const _ReceiptPainter({
    required this.paper,
    required this.ink,
    required this.line,
  });

  final Color paper;

  /// Outline and the highlighted total line.
  final Color ink;

  /// Plain text lines.
  final Color line;

  @override
  void paint(Canvas canvas, Size size) {
    const teeth = 5;
    const toothHeight = 6.0;
    final w = size.width;
    final h = size.height;
    final toothWidth = w / teeth;

    // Top edge, right edge, then the zig-zag from right to left.
    final zigzag = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - toothHeight);
    for (var i = 0; i < teeth; i++) {
      final right = w - i * toothWidth;
      zigzag
        ..lineTo(right - toothWidth / 2, h)
        ..lineTo(right - toothWidth, h - toothHeight);
    }
    zigzag.close();

    canvas.drawPath(zigzag, Paint()..color = paper);
    canvas.drawPath(
      zigzag,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round,
    );

    final stroke = Paint()
      ..color = line
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final left = w * 0.2;
    canvas
      ..drawLine(Offset(left, 20), Offset(w * 0.8, 20), stroke)
      ..drawLine(Offset(left, 34), Offset(w * 0.62, 34), stroke)
      ..drawLine(Offset(left, 48), Offset(w * 0.8, 48), stroke);
    stroke.color = ink;
    canvas.drawLine(Offset(left, 64), Offset(w * 0.46, 64), stroke);
  }

  @override
  bool shouldRepaint(_ReceiptPainter old) =>
      old.paper != paper || old.ink != ink || old.line != line;
}
