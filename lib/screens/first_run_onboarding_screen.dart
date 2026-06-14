import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_texts.dart';
import '../l10n/text_sets.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../widgets/app/app_bouncy_button.dart';

class FirstRunOnboardingScreen extends StatefulWidget {
  const FirstRunOnboardingScreen({super.key, required this.onCompleted});

  final Future<void> Function() onCompleted;

  @override
  State<FirstRunOnboardingScreen> createState() =>
      _FirstRunOnboardingScreenState();
}

class _FirstRunOnboardingScreenState extends State<FirstRunOnboardingScreen> {
  final _pageController = PageController();
  var _pageIndex = 0;
  var _isCompleting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_isCompleting) {
      return;
    }
    setState(() {
      _isCompleting = true;
    });
    await widget.onCompleted();
  }

  void _goToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = AppTexts.of(context).firstRunOnboarding;
    final slides = texts.slides;
    final textTheme = Theme.of(context).textTheme;
    final mediaQuery = MediaQuery.of(context);
    final safeHeight =
        mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    final pageViewHeight = math
        .min(math.max(safeHeight * 0.48, 300.0), 440.0)
        .toDouble();

    return Scaffold(
      key: const ValueKey('firstRunOnboardingScreen'),
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWarm,
                  borderRadius: AppRadius.panel,
                  border: Border.all(color: AppColors.borderWarm, width: 1.3),
                  boxShadow: AppShadows.hero,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        texts.title,
                        style: textTheme.headlineSmall?.copyWith(
                          color: AppColors.textStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        texts.subtitle,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        height: pageViewHeight,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: slides.length,
                          onPageChanged: (index) {
                            setState(() {
                              _pageIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Semantics(
                              label: texts.pageSemanticLabel(
                                currentPage: index + 1,
                                totalPages: slides.length,
                              ),
                              child: _FirstRunOnboardingSlide(
                                slide: slides[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _FirstRunOnboardingDots(
                        key: const ValueKey('firstRunOnboardingPageDots'),
                        count: slides.length,
                        activeIndex: _pageIndex,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          if (_pageIndex > 0) ...[
                            Expanded(
                              child: AppBouncyButton(
                                key: const ValueKey(
                                  'firstRunOnboardingPreviousButton',
                                ),
                                label: texts.previousButtonLabel,
                                icon: Icons.chevron_left_rounded,
                                variant: AppButtonVariant.neutral,
                                size: AppButtonSize.large,
                                onPressed: _isCompleting
                                    ? null
                                    : () => _goToPage(_pageIndex - 1),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                          ],
                          Expanded(
                            child: AppBouncyButton(
                              key: ValueKey(
                                _pageIndex == slides.length - 1
                                    ? 'firstRunOnboardingCompleteButton'
                                    : 'firstRunOnboardingNextButton',
                              ),
                              label: _pageIndex == slides.length - 1
                                  ? texts.startButtonLabel
                                  : texts.nextButtonLabel,
                              icon: _pageIndex == slides.length - 1
                                  ? Icons.flag_rounded
                                  : Icons.chevron_right_rounded,
                              size: AppButtonSize.large,
                              onPressed: _isCompleting
                                  ? null
                                  : () {
                                      if (_pageIndex == slides.length - 1) {
                                        _complete();
                                      } else {
                                        _goToPage(_pageIndex + 1);
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: _pageIndex < slides.length - 1
                            ? TextButton(
                                key: const ValueKey(
                                  'firstRunOnboardingSkipButton',
                                ),
                                onPressed: _isCompleting ? null : _complete,
                                child: Text(texts.skipButtonLabel),
                              )
                            : const SizedBox(height: 48),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstRunOnboardingSlide extends StatelessWidget {
  const _FirstRunOnboardingSlide({required this.slide});

  final FirstRunOnboardingSlideText slide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
                boxShadow: AppShadows.buttonSoft,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  slide.emoji,
                  style: textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            slide.title,
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textStrong,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            slide.body,
            style: textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final bullet in slide.bullets)
            _FirstRunOnboardingBullet(text: bullet),
        ],
      ),
    );
  }
}

class _FirstRunOnboardingBullet extends StatelessWidget {
  const _FirstRunOnboardingBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstRunOnboardingDots extends StatelessWidget {
  const _FirstRunOnboardingDots({
    super.key,
    required this.count,
    required this.activeIndex,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index += 1)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: index == activeIndex ? 22 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? AppColors.primary
                  : AppColors.brown300.withValues(alpha: 0.38),
              borderRadius: AppRadius.pill,
            ),
          ),
      ],
    );
  }
}
