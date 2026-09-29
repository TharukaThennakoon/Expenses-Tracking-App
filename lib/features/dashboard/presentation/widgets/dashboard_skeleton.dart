import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/skeleton.dart';

/// Placeholder in the shape of the dashboard while it loads.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SkeletonPulse(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          children: const [
            _Header(),
            SizedBox(height: 20),
            _SummaryCard(),
            SizedBox(height: 16),
            _BreakdownCard(),
            SizedBox(height: 16),
            _RecentCard(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SkeletonBox(width: 44, height: 44, radius: 22),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: 80, height: 11, radius: 6),
              SizedBox(height: 6),
              SkeletonBox(width: 104, height: 14, radius: 7),
            ],
          ),
        ),
        SkeletonBox(width: 42, height: 42, radius: 12),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    final bar = context.colors.skeletonOnPrimary;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 140, height: 30, radius: 10, color: bar),
          const SizedBox(height: 14),
          SkeletonBox(width: 102, height: 11, radius: 6, color: bar),
          const SizedBox(height: 8),
          SkeletonBox(width: 202, height: 40, radius: 10, color: bar),
          const SizedBox(height: 14),
          SkeletonBox(height: 8, radius: 4, color: bar),
          const SizedBox(height: 14),
          SkeletonBox(width: 165, height: 9, radius: 5, color: bar),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 110, height: 14, radius: 7),
          SizedBox(height: 14),
          SkeletonBox(height: 10, radius: 5),
          SizedBox(height: 14),
          _TwoBars(),
          SizedBox(height: 12),
          _TwoBars(),
        ],
      ),
    );
  }
}

class _TwoBars extends StatelessWidget {
  const _TwoBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SkeletonBox(height: 10, radius: 5)),
        SizedBox(width: 14),
        Expanded(child: SkeletonBox(height: 10, radius: 5)),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          _RecentRow(titleWidth: 95, subtitleWidth: 60, amountWidth: 64),
          SizedBox(height: 18),
          _RecentRow(titleWidth: 82, subtitleWidth: 50, amountWidth: 58),
          SizedBox(height: 18),
          _RecentRow(titleWidth: 88, subtitleWidth: 54, amountWidth: 66),
        ],
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({
    required this.titleWidth,
    required this.subtitleWidth,
    required this.amountWidth,
  });

  final double titleWidth;
  final double subtitleWidth;
  final double amountWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SkeletonBox(width: 40, height: 40, radius: 12),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(width: titleWidth, height: 11, radius: 6),
              const SizedBox(height: 7),
              SkeletonBox(width: subtitleWidth, height: 9, radius: 5),
            ],
          ),
        ),
        SkeletonBox(width: amountWidth, height: 12, radius: 6),
      ],
    );
  }
}
