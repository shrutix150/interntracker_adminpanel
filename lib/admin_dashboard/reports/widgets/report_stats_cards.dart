import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class ReportStatsCards extends StatelessWidget {
  const ReportStatsCards({
    super.key,
    required this.totalReports,
    required this.pendingReview,
    required this.reviewed,
    required this.correctionsRequested,
  });

  final int totalReports;
  final int pendingReview;
  final int reviewed;
  final int correctionsRequested;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = _resolveColumns(constraints.maxWidth);
        final double spacing = 16;
        final double cardWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            SizedBox(
              width: cardWidth,
              child: _ReportStatCard(
                title: 'Total Reports',
                value: '$totalReports',
                subtitle: 'Across the current submission cycle',
                icon: Icons.description_rounded,
                accentColor: AppColors.coolSky,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ReportStatCard(
                title: 'Pending Review',
                value: '$pendingReview',
                subtitle: 'Awaiting faculty review action',
                icon: Icons.hourglass_top_rounded,
                accentColor: AppColors.tangerineDream,
                animationDelay: const Duration(milliseconds: 80),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ReportStatCard(
                title: 'Reviewed',
                value: '$reviewed',
                subtitle: 'Checked and moved forward',
                icon: Icons.fact_check_rounded,
                accentColor: AppColors.aquamarine,
                animationDelay: const Duration(milliseconds: 160),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _ReportStatCard(
                title: 'Corrections Requested',
                value: '$correctionsRequested',
                subtitle: 'Needs follow-up from students',
                icon: Icons.rate_review_rounded,
                accentColor: AppColors.strawberryRed,
                animationDelay: const Duration(milliseconds: 240),
              ),
            ),
          ],
        );
      },
    );
  }

  static int _resolveColumns(double width) {
    if (width >= 960) {
      return 4;
    }
    if (width >= 720) {
      return 3;
    }
    if (width >= 460) {
      return 2;
    }
    return 1;
  }
}

class _ReportStatCard extends StatefulWidget {
  const _ReportStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.animationDelay = Duration.zero,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Duration animationDelay;

  @override
  State<_ReportStatCard> createState() => _ReportStatCardState();
}

class _ReportStatCardState extends State<_ReportStatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 520 + widget.animationDelay.inMilliseconds,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 22),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _hovered
                  ? widget.accentColor.withOpacity(0.2)
                  : AppColors.border,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.shadow.withOpacity(_hovered ? 1 : 0.78),
                blurRadius: _hovered ? 24 : 18,
                offset: Offset(0, _hovered ? 14 : 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: AppTextStyles.pageTitle.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
