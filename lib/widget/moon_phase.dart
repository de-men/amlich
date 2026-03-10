import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lunar day labels for key phases.
enum MoonPhaseType {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  thirdQuarter,
  waningCrescent
}

MoonPhaseType moonPhaseFromLunarDay(int lunarDay) {
  if (lunarDay == 1) return MoonPhaseType.newMoon;
  if (lunarDay >= 2 && lunarDay <= 6) return MoonPhaseType.waxingCrescent;
  if (lunarDay >= 7 && lunarDay <= 9) return MoonPhaseType.firstQuarter;
  if (lunarDay >= 10 && lunarDay <= 14) return MoonPhaseType.waxingGibbous;
  if (lunarDay == 15) return MoonPhaseType.fullMoon;
  if (lunarDay >= 16 && lunarDay <= 20) return MoonPhaseType.waningGibbous;
  if (lunarDay >= 21 && lunarDay <= 23) return MoonPhaseType.thirdQuarter;
  return MoonPhaseType.waningCrescent;
}

String moonPhaseLabel(MoonPhaseType type) {
  return switch (type) {
    MoonPhaseType.newMoon => 'Sóc',
    MoonPhaseType.firstQuarter => 'Thượng\nhuyền',
    MoonPhaseType.fullMoon => 'Vọng',
    MoonPhaseType.thirdQuarter => 'Hạ\nhuyền',
    _ => '',
  };
}

/// Widget that draws a moon phase based on the lunar day (1-30).
class MoonPhaseIcon extends StatelessWidget {
  const MoonPhaseIcon({
    required this.lunarDay,
    super.key,
    this.size = 24,
    this.color,
    this.shadowColor,
  });

  final int lunarDay;
  final double size;
  final Color? color;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final moonColor = color ?? const Color(0xFFF5E6CA);
    final shadow = shadowColor ?? const Color(0xFF1A1A2E);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MoonPhasePainter(
          lunarDay: lunarDay,
          moonColor: moonColor,
          shadowColor: shadow,
        ),
      ),
    );
  }
}

class _MoonPhasePainter extends CustomPainter {
  _MoonPhasePainter({
    required this.lunarDay,
    required this.moonColor,
    required this.shadowColor,
  });

  final int lunarDay;
  final Color moonColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the full moon circle (lit side)
    final basePaint = Paint()..color = moonColor;
    canvas.drawCircle(center, radius, basePaint);

    // Calculate illumination: 0 at day 1 (new), 1 at day 15 (full)
    // Using a simple cosine curve for smooth transition
    final phase = (lunarDay - 1) / 29.5;
    final illumination = (1 - math.cos(phase * 2 * math.pi)) / 2;

    final shadowPaint = Paint()..color = shadowColor;

    if (illumination < 0.5) {
      _paintLessHalf(
        canvas,
        center,
        radius,
        size,
        shadowPaint,
        basePaint,
        illumination,
      );
    } else {
      _paintMoreHalf(
        canvas,
        center,
        radius,
        size,
        shadowPaint,
        basePaint,
        illumination,
      );
    }
  }

  void _paintLessHalf(
    Canvas canvas,
    Offset center,
    double radius,
    Size size,
    Paint shadowPaint,
    Paint basePaint,
    double illumination,
  ) {
    final shadowWidth = radius * (1 - illumination * 2);
    final isWaxing = lunarDay <= 15;

    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..moveTo(center.dx, center.dy - radius);
    _addHalfEllipse(
      path,
      center,
      radius,
      shadowWidth,
      isRight: isWaxing,
    );
    path.close();

    final clipRight = Rect.fromLTWH(center.dx, 0, radius, size.height);
    final clipLeft = Rect.fromLTWH(0, 0, center.dx, size.height);

    final litPath = Path()..moveTo(center.dx, center.dy - radius);
    _addHalfEllipse(
      litPath,
      center,
      radius,
      shadowWidth,
      isRight: !isWaxing,
    );
    litPath.close();

    canvas
      ..save()
      ..clipRect(isWaxing ? clipRight : clipLeft)
      ..drawPath(path, shadowPaint)
      ..restore()
      ..save()
      ..clipRect(isWaxing ? clipLeft : clipRight)
      ..drawCircle(center, radius, shadowPaint)
      ..restore()
      ..save()
      ..clipRect(isWaxing ? clipLeft : clipRight)
      ..drawPath(litPath, basePaint)
      ..restore();
  }

  void _paintMoreHalf(
    Canvas canvas,
    Offset center,
    double radius,
    Size size,
    Paint shadowPaint,
    Paint basePaint,
    double illumination,
  ) {
    final litWidth = radius * ((illumination - 0.5) * 2);
    final isWaxing = lunarDay <= 15;

    final clipShadow = isWaxing
        ? Rect.fromLTWH(0, 0, center.dx, size.height)
        : Rect.fromLTWH(center.dx, 0, radius, size.height);

    final litPath = Path()..moveTo(center.dx, center.dy - radius);
    _addHalfEllipse(
      litPath,
      center,
      radius,
      litWidth,
      isRight: !isWaxing,
    );
    litPath.close();

    canvas
      ..save()
      ..clipRect(clipShadow)
      ..drawCircle(center, radius, shadowPaint)
      ..restore()
      ..save()
      ..clipRect(clipShadow)
      ..drawPath(litPath, basePaint)
      ..restore();
  }

  void _addHalfEllipse(
    Path path,
    Offset center,
    double radius,
    double ellipseWidth, {
    required bool isRight,
  }) {
    final rect = Rect.fromCenter(
      center: center,
      width: ellipseWidth * 2,
      height: radius * 2,
    );
    if (isRight) {
      path.arcTo(rect, -math.pi / 2, math.pi, false);
    } else {
      path.arcTo(rect, math.pi / 2, math.pi, false);
    }
  }

  @override
  bool shouldRepaint(_MoonPhasePainter oldDelegate) =>
      lunarDay != oldDelegate.lunarDay ||
      moonColor != oldDelegate.moonColor ||
      shadowColor != oldDelegate.shadowColor;
}
