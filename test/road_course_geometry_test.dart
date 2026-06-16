import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:jy_yamyam/widgets/road_painter.dart';

void main() {
  test('roadCourseNeedsCameraPreview is false when course fits viewport', () {
    expect(
      roadCourseNeedsCameraPreview(
        viewportSize: const Size(420, 640),
        duration: const Duration(minutes: 5),
      ),
      isFalse,
    );
  });

  test('roadCourseNeedsCameraPreview is true for long portrait courses', () {
    expect(
      roadCourseNeedsCameraPreview(
        viewportSize: const Size(420, 640),
        duration: const Duration(minutes: 15),
      ),
      isTrue,
    );
  });

  test('roadCourseNeedsCameraPreview is true for long landscape courses', () {
    expect(
      roadCourseNeedsCameraPreview(
        viewportSize: const Size(900, 420),
        duration: const Duration(minutes: 15),
      ),
      isTrue,
    );
  });
}
