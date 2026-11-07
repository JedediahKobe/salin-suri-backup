import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ChartSeries {
  const ChartSeries({required this.values, required this.colors});

  final List<double> values;

  /// One color = solid line, two or more = horizontal gradient (History chart is purple -> pink).
  final List<Color> colors;
}

/// Line chart used on Home (accordion body), Sensor page and History.
/// Redraws itself with a "draw-on" animation whenever [series] changes, which is what
/// makes the Pre/Post-filtration switch feel alive.
class LineChart extends StatefulWidget {
  const LineChart({
    super.key,
    required this.series,
    this.xLabels,
    this.minY = 6,
    this.maxY = 10,
    this.step = 1,
    this.height = 240,
    this.strokeWidth = 3,
  });

  final List<ChartSeries> series;
  final List<String>? xLabels;
  final double minY;
  final double maxY;
  final double step;
  final double height;
  final double strokeWidth;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void didUpdateWidget(covariant LineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameData(oldWidget.series, widget.series)) {
      _controller.forward(from: 0);
    }
  }

  /// Compare values, not identity, so an unrelated parent rebuild doesn't replay the animation.
  static bool _sameData(List<ChartSeries> a, List<ChartSeries> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final x = a[i].values, y = b[i].values;
      if (x.length != y.length) return false;
      for (var j = 0; j < x.length; j++) {
        if (x[j] != y[j]) return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _LineChartPainter(
            series: widget.series,
            xLabels: widget.xLabels,
            minY: widget.minY,
            maxY: widget.maxY,
            step: widget.step,
            strokeWidth: widget.strokeWidth,
            progress: Curves.easeOutCubic.transform(_controller.value),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.xLabels,
    required this.minY,
    required this.maxY,
    required this.step,
    required this.strokeWidth,
    required this.progress,
  });

  final List<ChartSeries> series;
  final List<String>? xLabels;
  final double minY;
  final double maxY;
  final double step;
  final double strokeWidth;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 34.0;
    const rightPad = 14.0;
    const topPad = 8.0;
    final bottomPad = xLabels == null ? 8.0 : 24.0;

    final plot = Rect.fromLTRB(
        leftPad, topPad, size.width - rightPad, size.height - bottomPad);

    final grid = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    // Gridlines + y labels
    for (double v = minY; v <= maxY + 0.001; v += step) {
      final y = plot.bottom - (v - minY) / (maxY - minY) * plot.height;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      _text(canvas, v.toStringAsFixed(0), Offset(plot.left - 8, y),
          alignRight: true);
    }

    // X labels
    final labels = xLabels;
    if (labels != null && labels.isNotEmpty) {
      for (var i = 0; i < labels.length; i++) {
        final x = _x(plot, i, labels.length);
        _text(canvas, labels[i], Offset(x, plot.bottom + 12), center: true);
      }
    }

    // Series
    for (final s in series) {
      if (s.values.length < 2) continue;
      final path = Path();
      for (var i = 0; i < s.values.length; i++) {
        final clamped = s.values[i].clamp(minY, maxY).toDouble();
        final x = _x(plot, i, s.values.length);
        final y = plot.bottom - (clamped - minY) / (maxY - minY) * plot.height;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      paint.shader = s.colors.length > 1
          ? LinearGradient(colors: s.colors)
              .createShader(Rect.fromLTRB(plot.left, 0, plot.right, 1))
          : null;
      if (s.colors.length == 1) paint.color = s.colors.first;

      // Draw-on animation: only paint the first `progress` of the path's length.
      final trimmed = Path();
      for (final PathMetric m in path.computeMetrics()) {
        trimmed.addPath(m.extractPath(0, m.length * progress), Offset.zero);
      }
      canvas.drawPath(trimmed, paint);
    }
  }

  double _x(Rect plot, int i, int count) =>
      plot.left + (count == 1 ? 0 : i / (count - 1)) * plot.width;

  void _text(Canvas canvas, String text, Offset anchor,
      {bool alignRight = false, bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppText.inter(12)),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = anchor.dx;
    if (alignRight) dx -= tp.width;
    if (center) dx -= tp.width / 2;
    tp.paint(canvas, Offset(dx, anchor.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.progress != progress ||
      !identical(old.series, series) ||
      old.xLabels != xLabels;
}
