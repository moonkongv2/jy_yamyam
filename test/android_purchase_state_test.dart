import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:jy_yamyam/services/in_app_purchase_client.dart';

void main() {
  for (final state in PurchaseStateWrapper.values) {
    test('native $state survives a restored plugin event', () {
      final purchase = GooglePlayPurchaseDetails.fromPurchase(
        PurchaseWrapper(
          orderId: 'order',
          packageName: 'com.yamyamrider.app',
          purchaseTime: 1,
          purchaseToken: 'token',
          signature: '',
          products: const ['vehicle_pack'],
          isAutoRenewing: false,
          originalJson: '{}',
          isAcknowledged: false,
          purchaseState: state,
        ),
      ).single..status = PurchaseStatus.restored;
      preserveAndroidPurchaseState(purchase);
      expect(purchase.status, switch (state) {
        PurchaseStateWrapper.pending => PurchaseStatus.pending,
        PurchaseStateWrapper.purchased => PurchaseStatus.restored,
        PurchaseStateWrapper.unspecified_state => PurchaseStatus.error,
      });
    });
  }
}
