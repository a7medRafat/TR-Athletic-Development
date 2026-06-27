import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../features/post_training/data/models/post_training_model.dart';
import '../../../../features/workload/data/models/workload_models.dart';
import '../../../../features/workload/domain/workload_calculator.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _monthAbbr = [
  'Jan','Feb','Mar','Apr','May','Jun',
  'Jul','Aug','Sep','Oct','Nov','Dec',
];

String _fmtDate(DateTime d) => '${_monthAbbr[d.month - 1]} ${d.day}';

// ── Entry point ───────────────────────────────────────────────────────────────

class WorkloadTab extends StatelessWidget {
  final List<PostTrainingModel> postSessions;

  const WorkloadTab({super.key, required this.postSessions});

  @override
  Widget build(BuildContext context) {
    final metrics = WorkloadCalculator().compute(postSessions, DateTime.now());

    if (!metrics.hasData) {
      return _EmptyState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metrics.isAcuteReady && metrics.isChronicReady)
            _AlertBanner(status: metrics.status)
          else
            _InsufficientDataBanner(
              isAcuteReady: metrics.isAcuteReady,
              isChronicReady: metrics.isChronicReady,
            ),
          SizedBox(height: 14.h),
          _MetricCardsGrid(metrics: metrics),
          SizedBox(height: 20.h),
          _DailyLoadCard(dailyLoads: metrics.dailyLoads),
          SizedBox(height: 14.h),
          _ChartCard(
            title: AppStrings.acuteVsChronic,
            subtitle: AppStrings.last28Days,
            child: _DualLineChart(
              acute: metrics.acuteHistory,
              chronic: metrics.chronicHistory,
            ),
          ),
          SizedBox(height: 14.h),
          _ChartCard(
            title: AppStrings.acwrHistory,
            subtitle: AppStrings.last28Days,
            child: _AcwrLineChart(acwrValues: metrics.acwrHistory),
          ),
          SizedBox(height: 20.h),
          _SummaryGrid(metrics: metrics),
        ],
      ),
    );
  }
}

// ── Alert banner ──────────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  final AcwrStatus status;

  const _AlertBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(status.icon, color: color, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  status.description,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Insufficient data banner ──────────────────────────────────────────────────

class _InsufficientDataBanner extends StatelessWidget {
  final bool isAcuteReady;
  final bool isChronicReady;

  const _InsufficientDataBanner({
    required this.isAcuteReady,
    required this.isChronicReady,
  });

  String get _title {
    if (!isAcuteReady) return 'Collecting Data (< 7 days)';
    return 'Collecting Data (< 4 weeks)';
  }

  String get _message {
    if (!isAcuteReady) {
      return 'Acute Load requires 7 days of sessions. '
          'Chronic Load requires 4 full weeks (28 days).';
    }
    return 'Acute Load is ready. '
        'Chronic Load and ACWR will be available after 4 weeks (28 days) of data.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_bottom_rounded,
              color: AppColors.primary,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _message,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 4 metric cards ────────────────────────────────────────────────────────────

class _MetricCardsGrid extends StatelessWidget {
  final WorkloadMetrics metrics;

  const _MetricCardsGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final statusColor = metrics.status.color;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 1.55,
      children: [
        _MetricCard(
          label: AppStrings.acuteLoad,
          value: metrics.isAcuteReady
              ? metrics.acuteLoad.toStringAsFixed(0)
              : '—',
          unit: metrics.isAcuteReady ? AppStrings.arbitraryUnits : '',
          icon: Icons.flash_on_rounded,
          color: metrics.isAcuteReady ? AppColors.primary : AppColors.textSecondary,
          subtitle: metrics.isAcuteReady ? null : '< 7 days data',
        ),
        _MetricCard(
          label: AppStrings.chronicLoad,
          value: metrics.isChronicReady
              ? metrics.chronicLoad.toStringAsFixed(0)
              : '—',
          unit: metrics.isChronicReady ? AppStrings.arbitraryUnits : '',
          icon: Icons.timeline_rounded,
          color: metrics.isChronicReady ? AppColors.accent : AppColors.textSecondary,
          subtitle: metrics.isChronicReady ? null : '< 4 weeks data',
        ),
        _MetricCard(
          label: AppStrings.acwr,
          value: (metrics.isAcuteReady && metrics.isChronicReady)
              ? metrics.acwr.toStringAsFixed(2)
              : '—',
          unit: '',
          icon: Icons.balance_rounded,
          color: (metrics.isAcuteReady && metrics.isChronicReady)
              ? statusColor
              : AppColors.textSecondary,
          subtitle: (metrics.isAcuteReady && metrics.isChronicReady)
              ? null
              : '< 4 weeks data',
        ),
        _MetricCard(
          label: AppStrings.workloadStatus,
          value: (metrics.isAcuteReady && metrics.isChronicReady)
              ? metrics.status.label
              : '—',
          unit: '',
          icon: (metrics.isAcuteReady && metrics.isChronicReady)
              ? metrics.status.icon
              : Icons.hourglass_empty_rounded,
          color: (metrics.isAcuteReady && metrics.isChronicReady)
              ? statusColor
              : AppColors.textSecondary,
          isStatus: true,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isStatus;
  final String? subtitle;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.isStatus = false,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 14.sp, color: color),
              ),
              const Spacer(),
              if (unit.isNotEmpty)
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: isStatus ? 13.sp : 18.sp,
                  fontWeight: FontWeight.w800,
                  color: isStatus ? color : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: AppColors.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Daily Load Card with week/month filter ────────────────────────────────────

enum _LoadRange { week, month }

class _DailyLoadCard extends StatefulWidget {
  final List<DailyLoad> dailyLoads; // always 28 entries, newest last

  const _DailyLoadCard({required this.dailyLoads});

  @override
  State<_DailyLoadCard> createState() => _DailyLoadCardState();
}

class _DailyLoadCardState extends State<_DailyLoadCard> {
  _LoadRange _range = _LoadRange.month;

  List<DailyLoad> get _filtered => _range == _LoadRange.week
      ? widget.dailyLoads.sublist(21) // last 7 of 28
      : widget.dailyLoads;

  String get _subtitle =>
      _range == _LoadRange.week ? 'This Week (7 days)' : 'This Month (28 days)';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.dailyLoadChart,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _subtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _ArrowFilterToggle(
                range: _range,
                onChanged: (r) => setState(() => _range = r),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _DailyLoadBarChart(dailyLoads: _filtered),
        ],
      ),
    );
  }
}

class _ArrowFilterToggle extends StatelessWidget {
  final _LoadRange range;
  final ValueChanged<_LoadRange> onChanged;

  const _ArrowFilterToggle({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isWeek = range == _LoadRange.week;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ArrowBtn(
          icon: Icons.chevron_left_rounded,
          active: isWeek,
          onTap: () => onChanged(_LoadRange.week),
          tooltip: 'This Week',
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text(
            isWeek ? 'Week' : 'Month',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        _ArrowBtn(
          icon: Icons.chevron_right_rounded,
          active: !isWeek,
          onTap: () => onChanged(_LoadRange.month),
          tooltip: 'This Month',
        ),
      ],
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final String tooltip;

  const _ArrowBtn({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Chart wrapper card ─────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

// ── Daily Load Bar Chart ──────────────────────────────────────────────────────

class _DailyLoadBarChart extends StatelessWidget {
  final List<DailyLoad> dailyLoads;

  const _DailyLoadBarChart({required this.dailyLoads});

  @override
  Widget build(BuildContext context) {
    if (dailyLoads.isEmpty) return const SizedBox.shrink();

    final maxLoad =
        dailyLoads.map((d) => d.load).fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 100.h,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dailyLoads.map((d) {
              final ratio = maxLoad > 0 ? d.load / maxLoad : 0.0;
              final barColor = d.load > 0 ? AppColors.primary : AppColors.border;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: Tooltip(
                    message:
                        '${_fmtDate(d.date)}: ${d.load.toStringAsFixed(0)} AU',
                    child: Container(
                      height: math.max(ratio * 90.h, d.load > 0 ? 4.h : 1.h),
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(3.r),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmtDate(dailyLoads.first.date),
              style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary),
            ),
            Text(
              _fmtDate(dailyLoads.last.date),
              style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
        if (maxLoad > 0) ...[
          SizedBox(height: 2.h),
          Text(
            'Max: ${maxLoad.toStringAsFixed(0)} AU',
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Acute vs Chronic Dual-Line Chart ─────────────────────────────────────────

class _DualLineChart extends StatelessWidget {
  final List<double> acute;
  final List<double> chronic;

  const _DualLineChart({required this.acute, required this.chronic});

  @override
  Widget build(BuildContext context) {
    final allValues = [...acute, ...chronic];
    final maxVal =
        allValues.fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: 120.h,
          child: CustomPaint(
            size: Size(double.infinity, 120.h),
            painter: _DualLinePainter(
              acute: acute,
              chronic: chronic,
              maxVal: maxVal > 0 ? maxVal : 1,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _LegendDot(color: AppColors.primary, label: 'Acute (7d)'),
            SizedBox(width: 16.w),
            _LegendDot(color: AppColors.accent, label: 'Chronic (28d)'),
          ],
        ),
      ],
    );
  }
}

class _DualLinePainter extends CustomPainter {
  final List<double> acute;
  final List<double> chronic;
  final double maxVal;

  _DualLinePainter({
    required this.acute,
    required this.chronic,
    required this.maxVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (acute.isEmpty) return;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5;

    // Draw 4 horizontal grid lines
    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    _drawLine(canvas, size, acute, AppColors.primary, dashed: false);
    _drawLine(canvas, size, chronic, AppColors.accent, dashed: true);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> values,
    Color color, {
    required bool dashed,
  }) {
    if (values.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final n = values.length;

    for (int i = 0; i < n; i++) {
      final x = size.width * (i / (n - 1));
      final y = size.height * (1 - values[i] / maxVal);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (dashed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    // Area fill
    final areaPath = Path.from(path);
    areaPath.lineTo(size.width, size.height);
    areaPath.lineTo(0, size.height);
    areaPath.close();
    canvas.drawPath(
      areaPath,
      Paint()
        ..color = color.withValues(alpha: 0.06)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashPath = Path();
    const dashLength = 6.0;
    const gapLength = 4.0;
    double distance = 0;
    bool drawing = true;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final segLen =
            math.min(drawing ? dashLength : gapLength, metric.length - distance);
        if (drawing) {
          dashPath.addPath(
            metric.extractPath(distance, distance + segLen),
            Offset.zero,
          );
        }
        distance += segLen;
        drawing = !drawing;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(_DualLinePainter old) =>
      old.acute != acute || old.chronic != chronic;
}

// ── ACWR Line Chart with color zones ─────────────────────────────────────────

class _AcwrLineChart extends StatelessWidget {
  final List<double> acwrValues;

  const _AcwrLineChart({required this.acwrValues});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 130.h,
          child: CustomPaint(
            size: Size(double.infinity, 130.h),
            painter: _AcwrPainter(values: acwrValues),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            _LegendBox(
              color: const Color(0xFF3B82F6),
              label: '< 0.80',
            ),
            SizedBox(width: 8.w),
            _LegendBox(color: AppColors.success, label: '0.80–1.30'),
            SizedBox(width: 8.w),
            _LegendBox(color: AppColors.warning, label: '1.30–1.50'),
            SizedBox(width: 8.w),
            _LegendBox(color: AppColors.error, label: '> 1.50'),
          ],
        ),
      ],
    );
  }
}

class _AcwrPainter extends CustomPainter {
  final List<double> values;
  static const double _maxY = 2.0;

  const _AcwrPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Draw colored zone bands
    void drawBand(double yMin, double yMax, Color color) {
      final top = size.height * (1 - math.min(yMax, _maxY) / _maxY);
      final bottom = size.height * (1 - math.max(yMin, 0) / _maxY);
      canvas.drawRect(
        Rect.fromLTRB(0, top, size.width, bottom),
        Paint()
          ..color = color.withValues(alpha: 0.12)
          ..style = PaintingStyle.fill,
      );
    }

    drawBand(0, 0.80, const Color(0xFF3B82F6));
    drawBand(0.80, 1.30, AppColors.success);
    drawBand(1.30, 1.50, AppColors.warning);
    drawBand(1.50, _maxY, AppColors.error);

    // Reference lines
    final refPaint = Paint()
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (final threshold in [0.80, 1.30, 1.50]) {
      final y = size.height * (1 - threshold / _maxY);
      refPaint.color = AppColors.border;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), refPaint);
    }

    // ACWR line
    final n = values.length;
    final path = Path();
    for (int i = 0; i < n; i++) {
      final x = size.width * (i / (n - 1));
      final y = size.height * (1 - values[i].clamp(0, _maxY) / _maxY);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot at current value
    if (n > 0) {
      final lastX = size.width;
      final lastY =
          size.height * (1 - values.last.clamp(0, _maxY) / _maxY);
      final dotColor = _colorForAcwr(values.last);
      canvas.drawCircle(
        Offset(lastX, lastY),
        4,
        Paint()..color = dotColor,
      );
      canvas.drawCircle(
        Offset(lastX, lastY),
        2,
        Paint()..color = Colors.white,
      );
    }

    // Y-axis labels
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    for (final v in [0.0, 0.80, 1.30, 1.50, 2.0]) {
      final y = size.height * (1 - v / _maxY);
      textPainter.text = TextSpan(
        text: v.toStringAsFixed(v == 0 ? 0 : 2),
        style: TextStyle(
          fontSize: 8.sp,
          color: AppColors.textSecondary,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - textPainter.height / 2));
    }
  }

  Color _colorForAcwr(double v) {
    if (v < 0.80) return const Color(0xFF3B82F6);
    if (v <= 1.30) return AppColors.success;
    if (v <= 1.50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  bool shouldRepaint(_AcwrPainter old) => old.values != values;
}

// ── Summary stats grid ────────────────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  final WorkloadMetrics metrics;

  const _SummaryGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.workloadSummary,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 2.8,
            children: [
              _SummaryStat(
                label: AppStrings.peakAcute,
                value: '${metrics.peakAcute.toStringAsFixed(0)} AU',
                color: AppColors.primary,
              ),
              _SummaryStat(
                label: AppStrings.peakChronic,
                value: '${metrics.peakChronic.toStringAsFixed(0)} AU',
                color: AppColors.accent,
              ),
              _SummaryStat(
                label: AppStrings.peakAcwr,
                value: metrics.peakAcwr.toStringAsFixed(2),
                color: _colorForAcwr(metrics.peakAcwr),
              ),
              _SummaryStat(
                label: AppStrings.avgDailyLoad,
                value: '${metrics.avgDailyLoad.toStringAsFixed(0)} AU',
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _colorForAcwr(double v) {
    if (v < 0.80) return const Color(0xFF3B82F6);
    if (v <= 1.30) return AppColors.success;
    if (v <= 1.50) return AppColors.warning;
    return AppColors.error;
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_heart_outlined,
              size: 56.sp,
              color: AppColors.textHint,
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.noWorkloadData,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppStrings.noWorkloadSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Legend helpers ────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.r,
          height: 3.r,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 9.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(fontSize: 8.sp, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
