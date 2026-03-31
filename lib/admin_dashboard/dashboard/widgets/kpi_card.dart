import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class KpiCard extends StatefulWidget {
  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.trendLabel,
    this.trendUp = true,
    this.animationDelay = Duration.zero,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final String? trendLabel;
  final bool trendUp;
  final Duration animationDelay;

  @override
  State<KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<KpiCard> {
  bool _isHovered = false;

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
            offset: Offset(0, (1 - value) * 28),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: _isHovered ? 1.015 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: _isHovered
                    ? widget.accentColor.withOpacity(0.28)
                    : AppColors.border,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow.withOpacity(_isHovered ? 1 : 0.74),
                  blurRadius: _isHovered ? 28 : 22,
                  offset: Offset(0, _isHovered ? 16 : 12),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 6,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(26),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                color: widget.accentColor.withOpacity(0.16),
                              ),
                              child: Icon(
                                widget.icon,
                                color: AppColors.textPrimary,
                                size: 24,
                              ),
                            ),
                            const Spacer(),
                            if (widget.trendLabel != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.trendUp
                                      ? AppColors.secondarySoft
                                      : AppColors.dangerSoft,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      widget.trendUp
                                          ? Icons.north_east_rounded
                                          : Icons.south_east_rounded,
                                      size: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.trendLabel!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.value,
                          style: AppTextStyles.display.copyWith(
                            fontSize: 30,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
