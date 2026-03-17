import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class OverviewBanner extends StatelessWidget {
  const OverviewBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.highlightLabel,
    required this.highlightValue,
    required this.secondaryLabel,
    required this.secondaryValue,
  });

  final String title;
  final String subtitle;
  final String highlightLabel;
  final String highlightValue;
  final String secondaryLabel;
  final String secondaryValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.coolSky.withOpacity(0.18),
            AppColors.aquamarine.withOpacity(0.16),
            AppColors.jasmine.withOpacity(0.26),
            AppColors.tangerineDream.withOpacity(0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.surface.withOpacity(0.92)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 34,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isCompact = constraints.maxWidth < 880;

          return isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _BannerContent(title: title, subtitle: subtitle),
                    const SizedBox(height: 22),
                    _BannerStats(
                      highlightLabel: highlightLabel,
                      highlightValue: highlightValue,
                      secondaryLabel: secondaryLabel,
                      secondaryValue: secondaryValue,
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: _BannerContent(title: title, subtitle: subtitle),
                    ),
                    const SizedBox(width: 24),
                    _BannerStats(
                      highlightLabel: highlightLabel,
                      highlightValue: highlightValue,
                      secondaryLabel: secondaryLabel,
                      secondaryValue: secondaryValue,
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _BannerContent extends StatelessWidget {
  const _BannerContent({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.surface.withOpacity(0.88)),
          ),
          child: Text(
            'InternTracker Command Center',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: AppTextStyles.display.copyWith(fontSize: 30, height: 1.15),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.76),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerStats extends StatelessWidget {
  const _BannerStats({
    required this.highlightLabel,
    required this.highlightValue,
    required this.secondaryLabel,
    required this.secondaryValue,
  });

  final String highlightLabel;
  final String highlightValue;
  final String secondaryLabel;
  final String secondaryValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.surface.withOpacity(0.92)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatTile(
            label: highlightLabel,
            value: highlightValue,
            accent: AppColors.coolSky,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.border.withOpacity(0.9)),
          ),
          _StatTile(
            label: secondaryLabel,
            value: secondaryValue,
            accent: AppColors.aquamarine,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 12,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: accent,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
