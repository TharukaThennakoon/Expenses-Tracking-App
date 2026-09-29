import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/currency/currency_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../expenses/presentation/utils/category_style.dart';
import '../../domain/entities/monthly_insights.dart';

/// "Where it went": donut of category shares plus a legend with percents.
///
/// Tap a segment or a legend row to highlight it; tap again to clear.
class CategoryDonutCard extends StatefulWidget {
  const CategoryDonutCard({
    super.key,
    required this.shares,
    required this.expenseCount,
  });

  final List<CategoryShare> shares;
  final int expenseCount;

  @override
  State<CategoryDonutCard> createState() => _CategoryDonutCardState();
}

class _CategoryDonutCardState extends State<CategoryDonutCard> {
  ExpenseCategory? _selected;

  @override
  void didUpdateWidget(CategoryDonutCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.shares.any((s) => s.category == _selected)) _selected = null;
  }

  void _toggle(ExpenseCategory category) =>
      setState(() => _selected = _selected == category ? null : category);

  @override
  Widget build(BuildContext context) {
    final shares = widget.shares;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where it went',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          if (shares.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No spending recorded this month.',
                style: TextStyle(color: context.colors.textSecondary),
              ),
            )
          else
            Row(
              children: [
                _Donut(
                  shares: shares,
                  selected: _selected,
                  expenseCount: widget.expenseCount,
                  onTapCategory: _toggle,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      for (final share in shares)
                        _LegendRow(
                          share: share,
                          dimmed:
                              _selected != null && _selected != share.category,
                          onTap: () => _toggle(share.category),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Donut extends StatelessWidget {
  const _Donut({
    required this.shares,
    required this.selected,
    required this.expenseCount,
    required this.onTapCategory,
  });

  final List<CategoryShare> shares;
  final ExpenseCategory? selected;
  final int expenseCount;
  final ValueChanged<ExpenseCategory> onTapCategory;

  static const double size = 128;
  static const double stroke = 20;

  /// Maps a tap to the segment under it (null if outside the ring).
  ExpenseCategory? _hit(Offset local) {
    final center = const Offset(size / 2, size / 2);
    final v = local - center;
    final r = v.distance;
    if (r < size / 2 - stroke - 6 || r > size / 2 + 4) return null;
    // Angle clockwise from 12 o'clock, in [0, 2π).
    final angle = (math.atan2(v.dy, v.dx) + math.pi / 2) % (2 * math.pi);
    final total = shares.fold<double>(0, (s, e) => s + e.amount);
    var start = 0.0;
    for (final share in shares) {
      final sweep = share.amount / total * 2 * math.pi;
      if (angle < start + sweep) return share.category;
      start += sweep;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final picked = selected == null
        ? null
        : shares.firstWhere((s) => s.category == selected);

    return Semantics(
      label:
          'Spending by category: '
          '${shares.map((s) => '${s.category.label} ${s.percent} percent').join(', ')}',
      child: GestureDetector(
        onTapUp: (d) {
          final category = _hit(d.localPosition);
          if (category != null) onTapCategory(category);
        },
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) => CustomPaint(
                  size: const Size.square(size),
                  painter: _DonutPainter(
                    shares: shares,
                    selected: selected,
                    progress: progress,
                    stroke: stroke,
                    gapColor: context.colors.surface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(stroke + 6),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: picked == null
                        ? [
                            Text(
                              '$expenseCount ${expenseCount == 1 ? 'item' : 'items'}',
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${shares.length} ${shares.length == 1 ? 'cat' : 'cats'}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ]
                        : [
                            Text(
                              picked.category.label,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              Formatters.wholeAmount(picked.amount),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              context.currency,
                              style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.shares,
    required this.selected,
    required this.progress,
    required this.stroke,
    required this.gapColor,
  });

  final List<CategoryShare> shares;
  final ExpenseCategory? selected;
  final double progress;
  final double stroke;
  final Color gapColor;

  /// Surface-coloured gap between touching segments, in pixels.
  static const double gapPx = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final total = shares.fold<double>(0, (s, e) => s + e.amount);
    if (total <= 0) return;

    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Gap as an angle at the ring's centre line (none for a single segment).
    final gap = shares.length > 1 ? gapPx / radius : 0.0;
    var start = -math.pi / 2;
    for (final share in shares) {
      final sweep = share.amount / total * 2 * math.pi * progress;
      final dimmed = selected != null && selected != share.category;
      paint.color = share.category.color.withValues(alpha: dimmed ? 0.25 : 1);
      if (sweep > gap) {
        canvas.drawArc(rect, start + gap / 2, sweep - gap, false, paint);
      }
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.shares != shares ||
      old.selected != selected ||
      old.progress != progress;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.share,
    required this.dimmed,
    required this.onTap,
  });

  final CategoryShare share;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: dimmed ? 0.4 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: share.category.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  share.category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Text(
                '${share.percent}%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
