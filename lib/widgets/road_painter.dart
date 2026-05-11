import 'dart:ui';

import 'package:flutter/material.dart';

Rect createRoadBounds(Size size) {
  final horizontalPadding = (size.width * 0.13).clamp(46.0, 62.0).toDouble();
  final verticalPadding = size.height * 0.06;

  return Rect.fromLTWH(
    horizontalPadding,
    verticalPadding,
    size.width - (horizontalPadding * 2),
    size.height - (verticalPadding * 2),
  );
}

Path createRoadPath(Size size) {
  final bounds = createRoadBounds(size);
  final left = bounds.left;
  final right = bounds.right;
  final top = bounds.top;
  final bottom = bounds.bottom;
  final height = bounds.height;
  final rowHeight = height / 9;

  return Path()
    ..moveTo(left, bottom)
    ..lineTo(right, bottom)
    ..lineTo(right, bottom - rowHeight)
    ..lineTo(left, bottom - rowHeight)
    ..lineTo(left, bottom - (rowHeight * 2))
    ..lineTo(right, bottom - (rowHeight * 2))
    ..lineTo(right, bottom - (rowHeight * 3))
    ..lineTo(left, bottom - (rowHeight * 3))
    ..lineTo(left, bottom - (rowHeight * 4))
    ..lineTo(right, bottom - (rowHeight * 4))
    ..lineTo(right, bottom - (rowHeight * 5))
    ..lineTo(left, bottom - (rowHeight * 5))
    ..lineTo(left, bottom - (rowHeight * 6))
    ..lineTo(right, bottom - (rowHeight * 6))
    ..lineTo(right, bottom - (rowHeight * 7))
    ..lineTo(left, bottom - (rowHeight * 7))
    ..lineTo(left, bottom - (rowHeight * 8))
    ..lineTo(right, bottom - (rowHeight * 8))
    ..lineTo(right, top);
}

PathMetric _roadMetric(Size size) {
  return createRoadPath(size).computeMetrics().first;
}

Tangent roadTangentForProgress(Size size, double progress) {
  final metric = _roadMetric(size);
  final distance = metric.length * progress.clamp(0.0, 1.0).toDouble();
  return metric.getTangentForOffset(distance)!;
}

Offset roadPointForProgress(Size size, double progress) {
  return roadTangentForProgress(size, progress).position;
}

bool roadIsFacingLeftForProgress(Size size, double progress) {
  final clampedProgress = progress.clamp(0.0, 1.0).toDouble();
  final tangent = roadTangentForProgress(size, clampedProgress);
  if (tangent.vector.dx.abs() > 0.01) {
    return tangent.vector.dx < 0;
  }

  final probeProgress = (clampedProgress + 0.015).clamp(0.0, 1.0).toDouble();
  final probeTangent = roadTangentForProgress(size, probeProgress);
  if (probeTangent.vector.dx.abs() > 0.01) {
    return probeTangent.vector.dx < 0;
  }

  final previousProgress = (clampedProgress - 0.015).clamp(0.0, 1.0).toDouble();
  final previousTangent = roadTangentForProgress(size, previousProgress);
  return previousTangent.vector.dx < 0;
}

class RoadPainter extends CustomPainter {
  const RoadPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final roadPath = createRoadPath(size);
    final roadWidth = (size.shortestSide * 0.07).clamp(24.0, 36.0).toDouble();
    final roadMetric = roadPath.computeMetrics().first;
    final progressDistance =
        roadMetric.length * progress.clamp(0.0, 1.0).toDouble();
    final progressPath = roadMetric.extractPath(0, progressDistance);

    final shadowPaint = Paint()
      ..color = const Color(0xFFE4C19D)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = roadWidth;
    final roadPaint = Paint()
      ..color = const Color(0xFFB6DCC5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = roadWidth;
    final progressPaint = Paint()
      ..color = const Color(0xFFFFC857)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = roadWidth;

    canvas.drawPath(roadPath.shift(const Offset(0, 9)), shadowPaint);
    canvas.drawPath(roadPath, roadPaint);
    if (progressDistance > 0) {
      canvas.drawPath(progressPath, progressPaint);
    }

    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.8;

    _drawDashedPath(canvas, roadPath, lanePaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 13.0;
    const gap = 16.0;

    for (final metric in path.computeMetrics()) {
      var distance = 18.0;
      while (distance < metric.length - 18) {
        final nextDistance = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, nextDistance), paint);
        distance += dashWidth + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
