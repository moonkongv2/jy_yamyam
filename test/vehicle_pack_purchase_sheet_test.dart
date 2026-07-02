import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jy_yamyam/controllers/vehicle_pack_purchase_controller.dart';
import 'package:jy_yamyam/models/purchase_entitlement.dart';
import 'package:jy_yamyam/services/local_purchase_entitlement_store.dart';
import 'package:jy_yamyam/widgets/purchases/vehicle_pack_purchase_sheet.dart';

import 'fakes/fake_iap_purchase_client.dart';

void main() {
  testWidgets('Vehicle pack purchase sheet loads product details', (
    tester,
  ) async {
    final harness = _PurchaseSheetHarness();
    addTearDown(harness.dispose);

    await _pumpSheet(tester, harness);
    await tester.pumpAndSettle();

    expect(harness.client.queriedProductIdSets, isNotEmpty);
    expect(find.text('Vehicle Pack'), findsOneWidget);
    expect(find.text(r'$2.99'), findsOneWidget);
    expect(find.text('소방차'), findsOneWidget);
    expect(find.text('버스'), findsOneWidget);
    expect(find.text('오토바이'), findsNothing);
    expect(find.text('슈퍼카'), findsNothing);
  });

  testWidgets('Vehicle pack purchase sheet starts purchase and restore', (
    tester,
  ) async {
    final harness = _PurchaseSheetHarness();
    addTearDown(harness.dispose);

    await _pumpSheet(tester, harness);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('vehiclePackBuyButton')));
    await tester.pump();
    expect(harness.client.boughtProducts, [harness.productDetails]);

    await tester.tap(find.byKey(const ValueKey('vehiclePackRestoreButton')));
    await tester.pump();
    expect(harness.client.restorePurchasesCallCount, 1);
  });

  testWidgets('Vehicle pack purchase sheet disables actions while pending', (
    tester,
  ) async {
    final controller = _StaticPurchaseController(
      VehiclePackPurchaseState(
        entitlement: const PurchaseEntitlement.locked(),
        status: VehiclePackPurchaseStatus.purchasePending,
        productDetails: fakeProductDetails(),
      ),
    );
    addTearDown(controller.dispose);

    await _pumpController(tester, controller);

    expect(find.text('구매가 처리 중이에요. 잠시만 기다려 주세요.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('vehiclePackBuyButton')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.byKey(const ValueKey('vehiclePackRestoreButton')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('Vehicle pack purchase sheet shows error and canceled states', (
    tester,
  ) async {
    final harness = _PurchaseSheetHarness();
    addTearDown(harness.dispose);

    await _pumpSheet(tester, harness);
    await tester.pumpAndSettle();

    harness.client.buyNonConsumableError = Exception('Billing failed.');
    await tester.tap(find.byKey(const ValueKey('vehiclePackBuyButton')));
    await tester.pumpAndSettle();
    expect(find.text('구매를 완료하지 못했어요. 잠시 후 다시 시도해 주세요.'), findsOneWidget);
    expect(find.textContaining('Billing failed'), findsNothing);
    expect(find.textContaining('IAPError'), findsNothing);
    expect(find.textContaining('storekit'), findsNothing);

    harness.client.emitPurchases([
      fakePurchaseDetails(status: PurchaseStatus.canceled),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('구매가 취소됐어요.'), findsOneWidget);
  });

  testWidgets('Vehicle pack purchase sheet shows success after purchase', (
    tester,
  ) async {
    final harness = _PurchaseSheetHarness();
    addTearDown(harness.dispose);

    await _pumpSheet(tester, harness);
    await tester.pumpAndSettle();

    harness.client.emitPurchases([
      fakePurchaseDetails(status: PurchaseStatus.purchased),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('차량팩이 열렸어요.'), findsOneWidget);
    expect(find.text('이미 열림'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('vehiclePackBuyButton')),
          )
          .onPressed,
      isNull,
    );
  });

  testWidgets('Vehicle pack purchase sheet shows success after restore', (
    tester,
  ) async {
    final harness = _PurchaseSheetHarness();
    addTearDown(harness.dispose);

    await _pumpSheet(tester, harness);
    await tester.pumpAndSettle();

    harness.client.emitPurchases([
      fakePurchaseDetails(status: PurchaseStatus.restored),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('구매 복원이 완료됐어요.'), findsOneWidget);
    expect(find.text('이미 열림'), findsOneWidget);
  });
}

Future<void> _pumpSheet(
  WidgetTester tester,
  _PurchaseSheetHarness harness,
) async {
  SharedPreferences.setMockInitialValues({});
  harness.controller.startListening();
  await _pumpController(tester, harness.controller);
}

Future<void> _pumpController(
  WidgetTester tester,
  VehiclePackPurchaseController controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Scaffold(body: VehiclePackPurchaseSheet(controller: controller)),
    ),
  );
  await tester.pump();
}

class _PurchaseSheetHarness {
  _PurchaseSheetHarness() : productDetails = fakeProductDetails() {
    client = FakeIapPurchaseClient(
      productDetailsResponse: ProductDetailsResponse(
        productDetails: [productDetails],
        notFoundIDs: const [],
      ),
    );
    controller = VehiclePackPurchaseController(
      purchaseClient: client,
      entitlementStore: const LocalPurchaseEntitlementStore(),
    );
  }

  final ProductDetails productDetails;
  late final FakeIapPurchaseClient client;
  late final VehiclePackPurchaseController controller;

  Future<void> dispose() async {
    controller.dispose();
    await client.dispose();
  }
}

class _StaticPurchaseController extends VehiclePackPurchaseController {
  _StaticPurchaseController(this._state)
    : super(
        purchaseClient: FakeIapPurchaseClient(),
        entitlementStore: const LocalPurchaseEntitlementStore(),
      );

  final VehiclePackPurchaseState _state;

  @override
  VehiclePackPurchaseState get state => _state;

  @override
  Future<void> loadProductDetails() async {}

  @override
  Future<bool> buyVehiclePack({String? applicationUserName}) async {
    return false;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}
}
