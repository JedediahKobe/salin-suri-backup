import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

enum AppIconType {
  home,
  filter,
  bell,
  settings,
  bulb,
  history,
  archive,
  trash,
  circleCheck,
  circleAlert,
  mailRead,
  filterLines,
  search,
}

/// Outline icons drawn to match the Figma navigation bar (house with door, funnel, bell,
/// cog). 24-unit grid, 2px round stroke, so they stay crisp at any size.
class AppIcon extends StatelessWidget {
  const AppIcon(this.type,
      {super.key, this.color, this.size = 30, this.strokeWidth = 2});

  final AppIconType type;
  final Color? color;
  final double size;
  final double strokeWidth;

  /// Icons exported from Figma live in assets/icons; everything else is drawn below.
  static const _svgAssets = {
    AppIconType.archive: 'assets/icons/archive.svg',
    AppIconType.trash: 'assets/icons/trash.svg',
    AppIconType.mailRead: 'assets/icons/mailRead.svg',
    AppIconType.filterLines: 'assets/icons/filter.svg',
    AppIconType.bulb: 'assets/icons/lightbulb.svg',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _svgAssets[type];
    if (asset != null) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color ?? AppColors.text, BlendMode.srcIn),
      );
    }
    return _painted();
  }

  Widget _painted() => CustomPaint(
        size: Size.square(size),
        painter: _IconPainter(type, color ?? AppColors.text, strokeWidth),
      );
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.type, this.color, this.strokeWidth);

  final AppIconType type;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
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
      case AppIconType.archive:
        _archive(canvas, paint);
      case AppIconType.trash:
        _trash(canvas, paint);
      case AppIconType.circleCheck:
        canvas.drawCircle(const Offset(12, 12), 9.5, paint);
        canvas.drawPath(
            Path()
              ..moveTo(7.8, 12.4)
              ..lineTo(10.7, 15.3)
              ..lineTo(16.4, 9.2),
            paint);
      case AppIconType.circleAlert:
        canvas.drawCircle(const Offset(12, 12), 9.5, paint);
        canvas.drawLine(const Offset(12, 7.2), const Offset(12, 13), paint);
        canvas.drawCircle(const Offset(12, 16.4), 0.4, paint);
      case AppIconType.mailRead:
        canvas.drawPath(
            Path()
              ..moveTo(3, 7.5)
              ..lineTo(3, 18)
              ..lineTo(21, 18)
              ..lineTo(21, 11),
            paint);
        canvas.drawPath(
            Path()
              ..moveTo(3, 7.5)
              ..lineTo(12, 13.5)
              ..lineTo(17, 10.2),
            paint);
        canvas.drawLine(const Offset(3, 7.5), const Offset(14, 7.5), paint);
        canvas.drawCircle(const Offset(19.5, 6), 2, Paint()..color = color);
      case AppIconType.filterLines:
        canvas.drawLine(const Offset(4, 7.5), const Offset(20, 7.5), paint);
        canvas.drawLine(const Offset(7, 12), const Offset(17, 12), paint);
        canvas.drawLine(const Offset(10, 16.5), const Offset(14, 16.5), paint);
      case AppIconType.search:
        canvas.drawCircle(const Offset(10.5, 10.5), 6.5, paint);
        canvas.drawLine(const Offset(15.5, 15.5), const Offset(21, 21), paint);
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

  /// Lightbulb with five light rays (top, both diagonals, both sides).
  void _bulb(Canvas c, Paint p) {
    // Globe: a large arc over the top, closed flat at the bottom.
    c.drawPath(
        Path()
          ..moveTo(9.3, 15.6)
          ..arcToPoint(const Offset(14.7, 15.6),
              radius: const Radius.circular(5.2),
              largeArc: true,
              clockwise: true)
          ..close(),
        p);
    // Screw base.
    c.drawLine(const Offset(9.9, 18.2), const Offset(14.1, 18.2), p);
    c.drawLine(const Offset(10.8, 20.6), const Offset(13.2, 20.6), p);
    // Rays around the globe (centre 12, 11.16).
    const cx = 12.0, cy = 11.16;
    for (final deg in [-90, -135, -45, 180, 0]) {
      final a = deg * math.pi / 180;
      c.drawLine(
        Offset(cx + 7.6 * math.cos(a), cy + 7.6 * math.sin(a)),
        Offset(cx + 9.8 * math.cos(a), cy + 9.8 * math.sin(a)),
        p,
      );
    }
  }

  /// Archive box: wide lid, body with a handle slot (Figma "bi:archive").
  void _archive(Canvas c, Paint p) {
    c.drawRRect(
        RRect.fromLTRBR(2.5, 4, 21.5, 9, const Radius.circular(1.5)), p);
    c.drawPath(
        Path()
          ..moveTo(4, 9)
          ..lineTo(4, 17.5)
          ..arcToPoint(const Offset(6.5, 20),
              radius: const Radius.circular(2.5), clockwise: true)
          ..lineTo(17.5, 20)
          ..arcToPoint(const Offset(20, 17.5),
              radius: const Radius.circular(2.5), clockwise: true)
          ..lineTo(20, 9),
        p);
    c.drawLine(const Offset(9.5, 13), const Offset(14.5, 13), p);
  }

  /// Trash can with lid, handle and two slats (Figma "coolicons:trash-full").
  void _trash(Canvas c, Paint p) {
    c.drawLine(const Offset(4, 6.5), const Offset(20, 6.5), p);
    c.drawPath(
        Path()
          ..moveTo(9, 6.5)
          ..lineTo(9, 4.5)
          ..arcToPoint(const Offset(10, 3.5),
              radius: const Radius.circular(1), clockwise: true)
          ..lineTo(14, 3.5)
          ..arcToPoint(const Offset(15, 4.5),
              radius: const Radius.circular(1), clockwise: true)
          ..lineTo(15, 6.5),
        p);
    c.drawPath(
        Path()
          ..moveTo(5.8, 6.5)
          ..lineTo(6.8, 19)
          ..arcToPoint(const Offset(8.8, 20.8),
              radius: const Radius.circular(2), clockwise: false)
          ..lineTo(15.2, 20.8)
          ..arcToPoint(const Offset(17.2, 19),
              radius: const Radius.circular(2), clockwise: false)
          ..lineTo(18.2, 6.5),
        p);
    c.drawLine(const Offset(10, 10.5), const Offset(10, 16.5), p);
    c.drawLine(const Offset(14, 10.5), const Offset(14, 16.5), p);
  }

  /// Clock with a counter-clockwise arrow (history).
  void _history(Canvas c, Paint p) {
    c.drawPath(
        Path()
          ..moveTo(3, 12)
          ..arcToPoint(const Offset(12, 3),
              radius: const Radius.circular(9), largeArc: true, clockwise: false)
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
  bool shouldRepaint(_IconPainter old) =>
      old.type != type || old.color != color || old.strokeWidth != strokeWidth;
}
