import 'package:flutter/material.dart';

import '../../catalogs/vehicle_catalog.dart';
import '../../catalogs/vehicle_unlock_catalog.dart';
import '../../controllers/vehicle_pack_purchase_controller.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'purchase_entitlement_scope.dart';

Future<void> showVehiclePackPurchaseSheet(
  BuildContext context, {
  VehiclePackPurchaseController? purchaseController,
}) {
  final controller =
      purchaseController ??
      PurchaseEntitlementScope.read(context)?.purchaseController;
  assert(controller != null, 'No VehiclePackPurchaseController found.');
  if (controller == null) {
    return Future<void>.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surfaceWarm,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => VehiclePackPurchaseSheet(controller: controller),
  );
}

class VehiclePackPurchaseSheet extends StatefulWidget {
  const VehiclePackPurchaseSheet({super.key, required this.controller});

  final VehiclePackPurchaseController controller;

  @override
  State<VehiclePackPurchaseSheet> createState() =>
      _VehiclePackPurchaseSheetState();
}

class _VehiclePackPurchaseSheetState extends State<VehiclePackPurchaseSheet> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final state = widget.controller.state;
      if (!state.vehiclePackUnlocked &&
          !state.hasProductDetails &&
          state.status != VehiclePackPurchaseStatus.loadingProduct) {
        widget.controller.loadProductDetails();
      }
    });
  }

  @override
  void didUpdateWidget(covariant VehiclePackPurchaseSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_handleControllerChanged);
    widget.controller.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _buyVehiclePack() async {
    await widget.controller.buyVehiclePack();
  }

  Future<void> _restorePurchases() async {
    await widget.controller.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.controller.state;
    final texts = _VehiclePackPurchaseTexts.forLocale(
      Localizations.localeOf(context),
    );
    final textTheme = Theme.of(context).textTheme;
    final productDetails = state.productDetails;
    final priceText = productDetails?.price ?? texts.loadingPrice;
    final titleText = productDetails?.title.trim().isNotEmpty == true
        ? productDetails!.title
        : texts.title;
    final isBusy =
        state.status == VehiclePackPurchaseStatus.loadingProduct ||
        state.status == VehiclePackPurchaseStatus.purchasePending;
    final canBuy =
        !state.vehiclePackUnlocked &&
        productDetails != null &&
        state.status != VehiclePackPurchaseStatus.purchasePending;
    final canRestore =
        state.status != VehiclePackPurchaseStatus.purchasePending;
    final includedVehicles = _includedVehicleLabels(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(
                      Icons.directions_car_filled_rounded,
                      color: AppColors.brown700,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppColors.textStrong,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        texts.oneTimePurchase,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _PurchaseInfoCard(
              title: texts.priceTitle,
              body: priceText,
              icon: Icons.payments_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            _PurchaseInfoCard(
              title: texts.offlineTitle,
              body: texts.offlineBody,
              icon: Icons.offline_pin_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              texts.includedVehiclesTitle,
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textStrong,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final label in includedVehicles)
                  _VehiclePill(label: label),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _StatusMessage(
              status: state.status,
              isUnlocked: state.vehiclePackUnlocked,
              errorMessage: state.errorMessage,
              texts: texts,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              key: const ValueKey('vehiclePackBuyButton'),
              onPressed: canBuy ? _buyVehiclePack : null,
              icon: Icon(
                isBusy ? Icons.hourglass_top_rounded : Icons.lock_open_rounded,
              ),
              label: Text(
                state.vehiclePackUnlocked
                    ? texts.unlockedButton
                    : texts.buyButton(priceText),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              key: const ValueKey('vehiclePackRestoreButton'),
              onPressed: canRestore ? _restorePurchases : null,
              icon: const Icon(Icons.restore_rounded),
              label: Text(texts.restoreButton),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              texts.guardianNote,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseInfoCard extends StatelessWidget {
  const _PurchaseInfoCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.72),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: AppColors.brown700),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehiclePill extends StatelessWidget {
  const _VehiclePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: AppRadius.pill,
        border: Border.all(color: AppColors.borderWarm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.status,
    required this.isUnlocked,
    required this.errorMessage,
    required this.texts,
  });

  final VehiclePackPurchaseStatus status;
  final bool isUnlocked;
  final String? errorMessage;
  final _VehiclePackPurchaseTexts texts;

  @override
  Widget build(BuildContext context) {
    final message = _message;
    if (message == null) {
      return const SizedBox.shrink();
    }

    final isError =
        status == VehiclePackPurchaseStatus.error ||
        status == VehiclePackPurchaseStatus.productNotFound ||
        status == VehiclePackPurchaseStatus.storeUnavailable;
    final backgroundColor = isError
        ? AppColors.errorContainer
        : AppColors.surfaceMint;
    final foregroundColor = isError
        ? AppColors.onErrorContainer
        : AppColors.textPrimary;
    final icon = isError ? Icons.error_outline_rounded : Icons.check_rounded;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: foregroundColor),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? get _message {
    if (status == VehiclePackPurchaseStatus.restoreCompleted) {
      return texts.restoreSuccessMessage;
    }

    if (isUnlocked) {
      return texts.successMessage;
    }

    return switch (status) {
      VehiclePackPurchaseStatus.idle => null,
      VehiclePackPurchaseStatus.loadingProduct => texts.loadingProductMessage,
      VehiclePackPurchaseStatus.productReady => null,
      VehiclePackPurchaseStatus.storeUnavailable =>
        texts.storeUnavailableMessage,
      VehiclePackPurchaseStatus.productNotFound => texts.productNotFoundMessage,
      VehiclePackPurchaseStatus.purchasePending => texts.pendingMessage,
      VehiclePackPurchaseStatus.purchaseCompleted => texts.successMessage,
      VehiclePackPurchaseStatus.restoreCompleted => texts.restoreSuccessMessage,
      VehiclePackPurchaseStatus.error =>
        errorMessage == null
            ? texts.errorMessage
            : texts.errorWithDetail(errorMessage!),
      VehiclePackPurchaseStatus.canceled => texts.canceledMessage,
    };
  }
}

List<String> _includedVehicleLabels(BuildContext context) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return [
    for (final vehicle in VehicleCatalog.all)
      if (!VehicleUnlockCatalog.freeVehicleIds.contains(vehicle.id))
        vehicle.labelForLanguage(languageCode),
  ];
}

class _VehiclePackPurchaseTexts {
  const _VehiclePackPurchaseTexts({
    required this.title,
    required this.oneTimePurchase,
    required this.priceTitle,
    required this.loadingPrice,
    required this.offlineTitle,
    required this.offlineBody,
    required this.includedVehiclesTitle,
    required this.loadingProductMessage,
    required this.pendingMessage,
    required this.successMessage,
    required this.restoreSuccessMessage,
    required this.errorMessage,
    required this.storeUnavailableMessage,
    required this.productNotFoundMessage,
    required this.canceledMessage,
    required this.restoreButton,
    required this.unlockedButton,
    required this.guardianNote,
    required this.buyButton,
    required this.errorWithDetail,
  });

  final String title;
  final String oneTimePurchase;
  final String priceTitle;
  final String loadingPrice;
  final String offlineTitle;
  final String offlineBody;
  final String includedVehiclesTitle;
  final String loadingProductMessage;
  final String pendingMessage;
  final String successMessage;
  final String restoreSuccessMessage;
  final String errorMessage;
  final String storeUnavailableMessage;
  final String productNotFoundMessage;
  final String canceledMessage;
  final String restoreButton;
  final String unlockedButton;
  final String guardianNote;
  final String Function(String price) buyButton;
  final String Function(String detail) errorWithDetail;

  static _VehiclePackPurchaseTexts forLocale(Locale locale) {
    if (locale.languageCode == 'ko') {
      return _VehiclePackPurchaseTexts(
        title: '차량팩',
        oneTimePurchase: '한 번 구매하면 추가 차량을 계속 사용할 수 있어요.',
        priceTitle: '가격',
        loadingPrice: '가격을 불러오는 중',
        offlineTitle: '오프라인 사용',
        offlineBody: '구매가 완료되면 이 기기에 저장되어 오프라인에서도 사용할 수 있어요.',
        includedVehiclesTitle: '포함 차량',
        loadingProductMessage: '스토어에서 차량팩 정보를 불러오는 중이에요.',
        pendingMessage: '구매가 처리 중이에요. 잠시만 기다려 주세요.',
        successMessage: '차량팩이 열렸어요.',
        restoreSuccessMessage: '구매 복원이 완료됐어요.',
        errorMessage: '구매를 완료하지 못했어요. 잠시 후 다시 시도해 주세요.',
        storeUnavailableMessage: '지금은 스토어에 연결할 수 없어요.',
        productNotFoundMessage: '스토어에서 차량팩을 찾을 수 없어요.',
        canceledMessage: '구매가 취소됐어요.',
        restoreButton: '구매 복원',
        unlockedButton: '이미 열림',
        guardianNote: '구매와 복원은 보호자 확인 후 진행되는 보호자용 기능입니다.',
        buyButton: (price) => '보호자 구매 $price',
        errorWithDetail: (detail) => '구매를 완료하지 못했어요. $detail',
      );
    }

    return _VehiclePackPurchaseTexts(
      title: 'Vehicle Pack',
      oneTimePurchase: 'Buy once to keep using the extra vehicles.',
      priceTitle: 'Price',
      loadingPrice: 'Loading price',
      offlineTitle: 'Works offline',
      offlineBody:
          'After purchase, access is saved on this device for offline use.',
      includedVehiclesTitle: 'Included vehicles',
      loadingProductMessage: 'Loading vehicle pack details from the store.',
      pendingMessage: 'The purchase is pending. Please wait a moment.',
      successMessage: 'The vehicle pack is unlocked.',
      restoreSuccessMessage: 'Purchases have been restored.',
      errorMessage: 'The purchase could not be completed. Please try again.',
      storeUnavailableMessage: 'The store is not available right now.',
      productNotFoundMessage: 'The vehicle pack was not found in the store.',
      canceledMessage: 'The purchase was canceled.',
      restoreButton: 'Restore Purchase',
      unlockedButton: 'Already Unlocked',
      guardianNote:
          'Purchases and restore are guardian-only actions after guardian check.',
      buyButton: (price) => 'Guardian Purchase $price',
      errorWithDetail: (detail) =>
          'The purchase could not be completed. $detail',
    );
  }
}
