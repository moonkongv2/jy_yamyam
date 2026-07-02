import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_texts.dart';
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
    final texts = AppTexts.of(context).purchases;
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
              texts.guardianGateTitle,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              texts.guardianGateSubtitle,
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
                      texts.guardianGatePrompt,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      texts.guardianGateChallenge,
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
                        hintText: texts.guardianGateAnswerHint,
                        errorText: _hasError
                            ? texts.guardianGateErrorMessage
                            : null,
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
                    child: Text(texts.guardianGateCancelButton),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey('guardianGateContinueButton'),
                    onPressed: canSubmit ? _submit : null,
                    child: Text(texts.guardianGateContinueButton),
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
