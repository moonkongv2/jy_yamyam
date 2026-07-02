import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> enterCurrentGuardianGateAnswer(WidgetTester tester) async {
  final answer = currentGuardianGateAnswer(tester);
  await tester.enterText(
    find.byKey(const ValueKey('guardianGateAnswerField')),
    answer,
  );
}

String currentGuardianGateAnswer(WidgetTester tester) {
  final challengeText = tester.widget<Text>(
    find.byKey(const ValueKey('guardianGateChallengeText')),
  );
  final question = challengeText.data;
  if (question == null) {
    fail('Guardian gate challenge text was not a plain text question.');
  }

  return guardianGateAnswerForQuestion(question);
}

String guardianGateAnswerForQuestion(String question) {
  final match = RegExp(
    r'^\s*(\d+)\s*([+-])\s*(\d+)\s*=\s*\?\s*$',
  ).firstMatch(question);
  if (match == null) {
    fail('Unsupported guardian gate challenge: $question');
  }

  final left = int.parse(match.group(1)!);
  final operator = match.group(2)!;
  final right = int.parse(match.group(3)!);
  final answer = switch (operator) {
    '+' => left + right,
    '-' => left - right,
    _ => throw StateError('Unsupported operator: $operator'),
  };

  return answer.toString();
}
