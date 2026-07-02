import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

const _guardianGateExpectedAnswer = '13';

Future<bool> showGuardianGateSheet(
  BuildContext context, {
  required VoidCallback onPassed,
}) async {
  final passed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surfaceWarm,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const GuardianGateSheet(),
  );
  if (passed == true) {
    onPassed();
    return true;
  }
  return false;
}

class GuardianGateSheet extends StatefulWidget {
  const GuardianGateSheet({super.key});

  @override
  State<GuardianGateSheet> createState() => _GuardianGateSheetState();
}

class _GuardianGateSheetState extends State<GuardianGateSheet> {
  final TextEditingController _answerController = TextEditingController();
  bool _hasError = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_answerController.text.trim() == _guardianGateExpectedAnswer) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() => _hasError = true);
  }

  @override
  Widget build(BuildContext context) {
    final texts = _GuardianGateTexts.forLocale(Localizations.localeOf(context));
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canSubmit = _answerController.text.trim().isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl,
          AppSpacing.xxl + bottomInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceYellow,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 72,
                height: 72,
                child: Icon(
                  Icons.family_restroom_rounded,
                  color: AppColors.brown700,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              texts.title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              texts.subtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.72),
                borderRadius: AppRadius.card,
                border: Border.all(color: AppColors.borderSoft),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      texts.prompt,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      texts.challenge,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.textStrong,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      key: const ValueKey('guardianGateAnswerField'),
                      controller: _answerController,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: InputDecoration(
                        hintText: texts.answerHint,
                        errorText: _hasError ? texts.errorMessage : null,
                      ),
                      onChanged: (_) {
                        if (_hasError) {
                          setState(() => _hasError = false);
                          return;
                        }
                        setState(() {});
                      },
                      onSubmitted: (_) {
                        if (canSubmit) {
                          _submit();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const ValueKey('guardianGateCancelButton'),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(texts.cancelButton),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('guardianGateContinueButton'),
                    onPressed: canSubmit ? _submit : null,
                    child: Text(texts.continueButton),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GuardianGateTexts {
  const _GuardianGateTexts({
    required this.title,
    required this.subtitle,
    required this.prompt,
    required this.challenge,
    required this.answerHint,
    required this.errorMessage,
    required this.cancelButton,
    required this.continueButton,
  });

  final String title;
  final String subtitle;
  final String prompt;
  final String challenge;
  final String answerHint;
  final String errorMessage;
  final String cancelButton;
  final String continueButton;

  static _GuardianGateTexts forLocale(Locale locale) {
    if (locale.languageCode == 'ko') {
      return const _GuardianGateTexts(
        title: '보호자 확인',
        subtitle: '차량팩 구매와 복원은 보호자만 진행할 수 있어요.',
        prompt: '계속하려면 아래 문제의 답을 입력해 주세요.',
        challenge: '8 + 5 = ?',
        answerHint: '답 입력',
        errorMessage: '답을 다시 확인해 주세요.',
        cancelButton: '닫기',
        continueButton: '계속',
      );
    }

    return const _GuardianGateTexts(
      title: 'Guardian Check',
      subtitle:
          'Vehicle pack purchases and restore are for parents or guardians.',
      prompt: 'To continue, enter the answer below.',
      challenge: '8 + 5 = ?',
      answerHint: 'Answer',
      errorMessage: 'Please check the answer and try again.',
      cancelButton: 'Close',
      continueButton: 'Continue',
    );
  }
}
