import 'dart:math' as math;

import 'package:flutter/material.dart';

enum AppIconType { home, filter, bell, settings, bulb, history }

/// Outline icons drawn to match the Figma navigation bar (house with door, funnel, bell,
/// cog). 24-unit grid, 2px round stroke, so they stay crisp at any size.
class AppIcon extends StatelessWidget {
  const AppIcon(this.type, {super.key, this.color = Colors.white, this.size = 30});

  final AppIconType type;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _IconPainter(type, color),
      );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.type, this.color);

  final AppIconType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (type) {
      case AppIconType.home:
        _home(canvas, paint);
      case AppIconType.filter:
        canvas.drawPath(
            Path()
              ..moveTo(22, 3)
              ..lineTo(2, 3)
              ..lineTo(10, 12.46)
              ..lineTo(10, 19)
              ..lineTo(14, 21)
              ..lineTo(14, 12.46)
              ..close(),
            paint);
      case AppIconType.bell:
        _bell(canvas, paint);
      case AppIconType.settings:
        _gear(canvas, paint);
      case AppIconType.bulb:
        _bulb(canvas, paint);
      case AppIconType.history:
        _history(canvas, paint);
    }
  }

  void _home(Canvas c, Paint p) {
    const r1 = Radius.circular(1), r2 = Radius.circular(2);
    c.drawPath(
        Path()
          ..moveTo(15, 21)
          ..lineTo(15, 13)
          ..arcToPoint(const Offset(14, 12), radius: r1, clockwise: false)
          ..lineTo(10, 12)
          ..arcToPoint(const Offset(9, 13), radius: r1, clockwise: false)
          ..lineTo(9, 21),
        p);
    c.drawPath(
        Path()
          ..moveTo(3, 10)
          ..arcToPoint(const Offset(3.709, 8.472), radius: r2)
          ..lineTo(10.709, 2.473)
          ..arcToPoint(const Offset(13.291, 2.473), radius: r2)
          ..lineTo(20.291, 8.472)
          ..arcToPoint(const Offset(21, 10), radius: r2)
          ..lineTo(21, 19)
          ..arcToPoint(const Offset(19, 21), radius: r2)
          ..lineTo(5, 21)
          ..arcToPoint(const Offset(3, 19), radius: r2)
          ..close(),
        p);
  }

  void _bell(Canvas c, Paint p) {
    c.drawPath(
        Path()
          ..moveTo(10.268, 21)
          ..arcToPoint(const Offset(13.732, 21),
              radius: const Radius.circular(2), clockwise: false),
        p);
    c.drawPath(
        Path()
          ..moveTo(3.262, 15.326)
          ..arcToPoint(const Offset(4, 17),
              radius: const Radius.circular(1), clockwise: false)
          ..lineTo(20, 17)
          ..arcToPoint(const Offset(20.74, 15.326),
              radius: const Radius.circular(1), clockwise: false)
          ..cubicTo(19.41, 13.956, 18, 12.499, 18, 8)
          ..arcToPoint(const Offset(6, 8),
              radius: const Radius.circular(6), clockwise: false)
          ..cubicTo(6, 12.499, 4.589, 13.956, 3.262, 15.326),
        p);
  }

  /// Lightbulb with light rays: the bulb is scaled down to leave room for the rays.
  void _bulb(Canvas c, Paint p) {
    c.save();
    c.translate(12, 13);
    c.scale(0.78);
    c.translate(-12, -12);
    c.drawPath(
        Path()
          ..moveTo(15, 14)
          ..cubicTo(15.2, 13, 15.7, 12.3, 16.5, 11.5)
          ..cubicTo(17.5, 10.6, 18, 9.3, 18, 8)
          ..arcToPoint(const Offset(6, 8),
              radius: const Radius.circular(6), clockwise: false)
          ..cubicTo(6, 9, 6.2, 10.2, 7.5, 11.5)
          ..cubicTo(8.2, 12.2, 8.8, 13, 9, 14)
          ..close(),
        p);
    c.drawLine(const Offset(9, 18), const Offset(15, 18), p);
    c.drawLine(const Offset(10, 22), const Offset(14, 22), p);
    c.restore();
    // Rays (top, upper diagonals, sides) around the globe.
    const cx = 12.0, cy = 9.9;
    for (final deg in [-90, -135, -45, 180, 0]) {
      final a = deg * math.pi / 180;
      c.drawLine(
        Offset(cx + 6.8 * math.cos(a), cy + 6.8 * math.sin(a)),
        Offset(cx + 8.8 * math.cos(a), cy + 8.8 * math.sin(a)),
        p,
      );
    }
  }

  /// Clock with a counter-clockwise arrow (history).
  void _history(Canvas c, Paint p) {
    c.drawPath(
        Path()
          ..moveTo(3, 12)
          ..arcToPoint(const Offset(12, 3),
              radius: const Radius.circular(9), largeArc: true, clockwise: true)
          ..arcToPoint(const Offset(5.26, 5.74),
              radius: const Radius.circular(9.75), clockwise: false)
          ..lineTo(3, 8),
        p);
    c.drawPath(
        Path()
          ..moveTo(3, 3)
          ..lineTo(3, 8)
          ..lineTo(8, 8),
        p);
    c.drawPath(
        Path()
          ..moveTo(12, 7)
          ..lineTo(12, 12)
          ..lineTo(16, 14),
        p);
  }

  void _gear(Canvas c, Paint p) {
    const teeth = 8, outer = 9.6, inner = 7.4;
    final path = Path();
    var first = true;
    for (var i = 0; i < teeth * 2; i++) {
      // Each tooth is a short plateau: two points at the outer radius, two at the inner.
      final base = (i / (teeth * 2)) * 2 * math.pi;
      final step = math.pi / (teeth * 2);
      final r = i.isEven ? outer : inner;
      for (final a in [base - step * 0.28, base + step * 0.28]) {
        final pt = Offset(12 + r * math.cos(a), 12 + r * math.sin(a));
        if (first) {
          path.moveTo(pt.dx, pt.dy);
          first = false;
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
    }
    path.close();
    c.drawPath(path, p);
    c.drawCircle(const Offset(12, 12), 3, p);
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.type != type || old.color != color;
}
