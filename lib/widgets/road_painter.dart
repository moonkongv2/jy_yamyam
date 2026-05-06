import 'package:flutter/material.dart';

Rect createRoadBounds(Size size) {
  final horizontalPadding = size.width * 0.1;
  final roadHeight = (size.height * 0.18).clamp(54.0, 82.0).toDouble();
  final centerY = size.height * 0.62;

  return Rect.fromLTWH(
    horizontalPadding,
    centerY - (roadHeight / 2),
    size.width - (horizontalPadding * 2),
    roadHeight,
  );
}

class RoadPainter extends CustomPainter {
  const RoadPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final roadBounds = createRoadBounds(size);
    final roadRadius = Radius.circular(roadBounds.height / 2);
    final progressWidth =
        roadBounds.width * progress.clamp(0.0, 1.0).toDouble();
    final progressBounds = Rect.fromLTWH(
      roadBounds.left,
      roadBounds.top,
      progressWidth,
      roadBounds.height,
    );

    final shadowPaint = Paint()..color = const Color(0xFFE9C8A6);
    final roadPaint = Paint()..color = const Color(0xFF8EC5A8);
    final progressPaint = Paint()..color = const Color(0xFFFFC857);

    canvas.drawRRect(
      RRect.fromRectAndRadius(roadBounds.translate(0, 10), roadRadius),
      shadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(roadBounds, roadRadius),
      roadPaint,
    );
    if (progressBounds.width > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(progressBounds, roadRadius),
        progressPaint,
      );
    }

    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    _drawDashedLine(
      canvas,
      Offset(roadBounds.left + 16, roadBounds.center.dy),
      Offset(roadBounds.right - 16, roadBounds.center.dy),
      lanePaint,
    );
    _drawMilestones(canvas, roadBounds);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 14.0;
    const gap = 10.0;
    var x = start.dx;

    while (x < end.dx) {
      final nextX = (x + dashWidth).clamp(start.dx, end.dx).toDouble();
      canvas.drawLine(Offset(x, start.dy), Offset(nextX, end.dy), paint);
      x += dashWidth + gap;
    }
  }

  void _drawMilestones(Canvas canvas, Rect roadBounds) {
    final passedPaint = Paint()..color = const Color(0xFFFFF4A3);
    final upcomingPaint = Paint()..color = Colors.white.withValues(alpha: 0.62);
    final postPaint = Paint()
      ..color = const Color(0xFF5B4636).withValues(alpha: 0.38)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var index = 1; index < 10; index += 1) {
      final milestoneProgress = index / 10;
      final x = roadBounds.left + (roadBounds.width * milestoneProgress);
      final isPassed = progress >= milestoneProgress;
      final center = Offset(x, roadBounds.top - 8);
      final markerPaint = isPassed ? passedPaint : upcomingPaint;

      canvas.drawLine(
        Offset(x, roadBounds.top + 3),
        Offset(x, roadBounds.top - 18),
        postPaint,
      );
      canvas.drawCircle(center, 8, markerPaint);
      canvas.drawCircle(
        center,
        8,
        Paint()
          ..color = const Color(0xFF5B4636).withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
