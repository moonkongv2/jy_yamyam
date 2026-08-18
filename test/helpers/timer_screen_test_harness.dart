import 'package:flutter_test/flutter_test.dart';

Future<void> finishCoursePreview(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 30; i += 1) {
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump();
}
