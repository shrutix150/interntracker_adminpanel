import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';

class DashboardChartCard extends StatefulWidget {
  const DashboardChartCard.line({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lineData,
    this.animationDelay = Duration.zero,
  }) : donutData = null,
       chartType = _ChartType.line;

  const DashboardChartCard.donut({
    super.key,
    required this.title,
    required this.subtitle,
    required this.donutData,
    this.animationDelay = Duration.zero,
  }) : lineData = null,
       chartType = _ChartType.donut;

  final String title;
  final String subtitle;
  final DashboardLineChartData? lineData;
  final DashboardDonutChartData? donutData;
  final Duration animationDelay;
  final _ChartType chartType;

  @override
  State<DashboardChartCard> createState() => _DashboardChartCardState();
}

class _DashboardChartCardState extends State<DashboardChartCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: 560 + widget.animationDelay.inMilliseconds,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: _isHovered ? 1.01 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _isHovered
                    ? AppColors.coolSky.withOpacity(0.22)
                    : AppColors.border,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.shadow.withOpacity(_isHovered ? 1 : 0.75),
                  blurRadius: _isHovered ? 28 : 22,
                  offset: Offset(0, _isHovered ? 16 : 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.title,
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 19),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: widget.chartType == _ChartType.line
                      ? _LineChartContent(data: widget.lineData!)
                      : _DonutChartContent(data: widget.donutData!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChartContent extends StatelessWidget {
  const _LineChartContent({required this.data});

  final DashboardLineChartData data;

  @override
  Widget build(BuildContext context) {
    if (data.points.isEmpty ||
        data.points.every((DashboardLinePoint point) => point.value <= 0)) {
      return const _ChartEmptyState(
        message: 'No trend data available yet.',
        icon: Icons.show_chart_rounded,
      );
    }

    final double highestValue = data.points
        .map((point) => point.value)
        .reduce((current, next) => current > next ? current : next);
    final double maxY = ((highestValue / 20).ceil() * 20 + 20).toDouble();

    return Column(
      children: <Widget>[
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: (data.points.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: AppColors.border, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final int index = value.toInt();
                      if (index < 0 || index >= data.points.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          data.points[index].label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => AppColors.textPrimary,
                  getTooltipItems: (spots) {
                    return spots
                        .map((spot) {
                          final int index = spot.x.toInt();
                          return LineTooltipItem(
                            '${data.points[index].label}: ${spot.y.toInt()}',
                            AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textOnDark,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        })
                        .toList(growable: false);
                  },
                ),
              ),
              lineBarsData: <LineChartBarData>[
                LineChartBarData(
                  spots: data.points
                      .asMap()
                      .entries
                      .map(
                        (entry) =>
                            FlSpot(entry.key.toDouble(), entry.value.value),
                      )
                      .toList(growable: false),
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: <Color>[AppColors.coolSky, AppColors.aquamarine],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        AppColors.coolSky.withOpacity(0.22),
                        AppColors.aquamarine.withOpacity(0.04),
                      ],
                    ),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4.5,
                        color: AppColors.surface,
                        strokeWidth: 3,
                        strokeColor: AppColors.coolSky,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const <Widget>[
            _LegendBadge(color: AppColors.coolSky, label: 'Monthly interns'),
            _LegendBadge(color: AppColors.aquamarine, label: 'Growth trend'),
          ],
        ),
      ],
    );
  }
}

class _DonutChartContent extends StatelessWidget {
  const _DonutChartContent({required this.data});

  final DashboardDonutChartData data;

  @override
  Widget build(BuildContext context) {
    final int total = data.sections.fold<int>(
      0,
      (sum, item) => sum + item.value,
    );

    if (data.sections.isEmpty || total <= 0) {
      return const _ChartEmptyState(
        message: 'No internship status data available yet.',
        icon: Icons.donut_small_rounded,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 360;

        return compact
            ? Column(
                children: <Widget>[
                  Expanded(
                    child: _DonutChartFigure(
                      sections: data.sections,
                      total: total,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DonutLegend(sections: data.sections),
                ],
              )
            : Row(
                children: <Widget>[
                  Expanded(
                    child: _DonutChartFigure(
                      sections: data.sections,
                      total: total,
                    ),
                  ),
                  const SizedBox(width: 18),
                  SizedBox(
                    width: 160,
                    child: _DonutLegend(sections: data.sections),
                  ),
                ],
              );
      },
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState({
    required this.message,
    required this.icon,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartFigure extends StatelessWidget {
  const _DonutChartFigure({required this.sections, required this.total});

  final List<DashboardDonutSectionData> sections;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        PieChart(
          PieChartData(
            sectionsSpace: 3,
            centerSpaceRadius: 52,
            startDegreeOffset: -90,
            sections: sections
                .map(
                  (section) => PieChartSectionData(
                    color: section.color,
                    value: section.value.toDouble(),
                    radius: 52,
                    showTitle: false,
                  ),
                )
                .toList(growable: false),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '$total',
              style: AppTextStyles.pageTitle.copyWith(
                fontSize: 28,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Internships',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  const _DonutLegend({required this.sections});

  final List<DashboardDonutSectionData> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: sections
          .map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _DonutLegendRow(section: section),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DonutLegendRow extends StatelessWidget {
  const _DonutLegendRow({required this.section});

  final DashboardDonutSectionData section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: section.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              section.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            section.value.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendBadge extends StatelessWidget {
  const _LegendBadge({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardLineChartData {
  const DashboardLineChartData({required this.points});

  final List<DashboardLinePoint> points;
}

class DashboardLinePoint {
  const DashboardLinePoint({required this.label, required this.value});

  final String label;
  final double value;
}

class DashboardDonutChartData {
  const DashboardDonutChartData({required this.sections});

  final List<DashboardDonutSectionData> sections;
}

class DashboardDonutSectionData {
  const DashboardDonutSectionData({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

enum _ChartType { line, donut }
