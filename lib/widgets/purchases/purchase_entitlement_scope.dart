import 'package:flutter/widgets.dart';

import '../../controllers/vehicle_pack_purchase_controller.dart';
import '../../models/purchase_entitlement.dart';

class PurchaseEntitlementScope extends InheritedWidget {
  const PurchaseEntitlementScope({
    super.key,
    required this.entitlement,
    required this.purchaseController,
    required super.child,
  });

  final PurchaseEntitlement entitlement;
  final VehiclePackPurchaseController? purchaseController;

  static PurchaseEntitlementScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No PurchaseEntitlementScope found in context.');
    return scope!;
  }

  static PurchaseEntitlementScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PurchaseEntitlementScope>();
  }

  static PurchaseEntitlementScope? read(BuildContext context) {
    return context
            .getElementForInheritedWidgetOfExactType<PurchaseEntitlementScope>()
            ?.widget
        as PurchaseEntitlementScope?;
  }

  @override
  bool updateShouldNotify(PurchaseEntitlementScope oldWidget) {
    return oldWidget.entitlement != entitlement ||
        oldWidget.purchaseController != purchaseController;
  }
}
