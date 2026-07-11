import 'package:flutter/material.dart';

import '../../catalogs/vehicle_catalog.dart';
import '../../catalogs/vehicle_unlock_catalog.dart';
import '../../controllers/vehicle_pack_purchase_controller.dart';
import '../../l10n/app_texts.dart';
import '../../l10n/text_sets.dart';
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
          state.status != VehiclePackPurchaseStatus.loadingProduct &&
          state.status != VehiclePackPurchaseStatus.restoring) {
        widget.controller.loadProductDetails(
          preserveStatusOnSuccess:
              state.status == VehiclePackPurchaseStatus.restoreNotFound,
        );
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
    final texts = AppTexts.of(context).purchases;
    final textTheme = Theme.of(context).textTheme;
    final productDetails = state.productDetails;
    final priceText = productDetails?.price ?? texts.vehiclePackLoadingPrice;
    final titleText = productDetails?.title.trim().isNotEmpty == true
        ? productDetails!.title
        : texts.vehiclePackTitle;
    final isBusy =
        state.status == VehiclePackPurchaseStatus.loadingProduct ||
        state.status == VehiclePackPurchaseStatus.purchasePending ||
        state.status == VehiclePackPurchaseStatus.restoring;
    final canBuy =
        !state.vehiclePackUnlocked &&
        state.status != VehiclePackPurchaseStatus.purchasePending &&
        state.status != VehiclePackPurchaseStatus.restoring;
    final canRestore =
        state.status != VehiclePackPurchaseStatus.purchasePending &&
        state.status != VehiclePackPurchaseStatus.restoring;
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
                        texts.vehiclePackOneTimePurchase,
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
              title: texts.vehiclePackPriceTitle,
              body: priceText,
              icon: Icons.payments_rounded,
            ),
            const SizedBox(height: AppSpacing.md),
            _PurchaseInfoCard(
              title: texts.vehiclePackOfflineTitle,
              body: texts.vehiclePackOfflineBody,
              icon: Icons.offline_pin_rounded,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              texts.vehiclePackIncludedVehiclesTitle,
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
                    ? texts.vehiclePackUnlockedButton
                    : productDetails == null
                    ? texts.settingsVehiclePackUnlockButton
                    : texts.vehiclePackBuyButton(priceText),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              key: const ValueKey('vehiclePackRestoreButton'),
              onPressed: canRestore ? _restorePurchases : null,
              icon: const Icon(Icons.restore_rounded),
              label: Text(texts.vehiclePackRestoreButton),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              texts.vehiclePackGuardianNote,
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
    required this.texts,
  });

  final VehiclePackPurchaseStatus status;
  final bool isUnlocked;
  final PurchaseTextSet texts;

  @override
  Widget build(BuildContext context) {
    final message = _message;
    if (message == null) {
      return const SizedBox.shrink();
    }

    final isError =
        status == VehiclePackPurchaseStatus.error ||
        status == VehiclePackPurchaseStatus.productNotFound ||
        status == VehiclePackPurchaseStatus.storeUnavailable ||
        status == VehiclePackPurchaseStatus.restoreNotFound;
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
      return texts.vehiclePackRestoreSuccessMessage;
    }

    if (isUnlocked) {
      return texts.vehiclePackSuccessMessage;
    }

    return switch (status) {
      VehiclePackPurchaseStatus.idle => null,
      VehiclePackPurchaseStatus.loadingProduct =>
        texts.vehiclePackLoadingProductMessage,
      VehiclePackPurchaseStatus.productReady => null,
      VehiclePackPurchaseStatus.storeUnavailable =>
        texts.vehiclePackStoreUnavailableMessage,
      VehiclePackPurchaseStatus.productNotFound =>
        texts.vehiclePackProductNotFoundMessage,
      VehiclePackPurchaseStatus.purchasePending =>
        texts.vehiclePackPendingMessage,
      VehiclePackPurchaseStatus.purchaseCompleted =>
        texts.vehiclePackSuccessMessage,
      VehiclePackPurchaseStatus.restoring => texts.vehiclePackRestoringMessage,
      VehiclePackPurchaseStatus.restoreNotFound =>
        texts.vehiclePackRestoreNotFoundMessage,
      VehiclePackPurchaseStatus.restoreCompleted =>
        texts.vehiclePackRestoreSuccessMessage,
      VehiclePackPurchaseStatus.error => texts.vehiclePackErrorMessage,
      VehiclePackPurchaseStatus.canceled => texts.vehiclePackCanceledMessage,
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
