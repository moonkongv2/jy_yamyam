import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../constants/iap_product_ids.dart';
import '../models/purchase_entitlement.dart';
import '../services/iap_purchase_client.dart';
import '../services/local_purchase_entitlement_store.dart';

enum VehiclePackPurchaseStatus {
  idle,
  loadingProduct,
  productReady,
  storeUnavailable,
  productNotFound,
  purchasePending,
  purchaseCompleted,
  restoring,
  restoreNotFound,
  restoreCompleted,
  error,
  canceled,
}

class VehiclePackPurchaseState {
  const VehiclePackPurchaseState({
    required this.entitlement,
    this.status = VehiclePackPurchaseStatus.idle,
    this.productDetails,
    this.errorMessage,
  });

  final PurchaseEntitlement entitlement;
  final VehiclePackPurchaseStatus status;
  final ProductDetails? productDetails;
  final String? errorMessage;

  bool get vehiclePackUnlocked => entitlement.vehiclePackUnlocked;
  bool get hasProductDetails => productDetails != null;
  bool get isPurchasePending =>
      status == VehiclePackPurchaseStatus.purchasePending;

  VehiclePackPurchaseState copyWith({
    PurchaseEntitlement? entitlement,
    VehiclePackPurchaseStatus? status,
    Object? productDetails = _productDetailsUnset,
    Object? errorMessage = _errorMessageUnset,
  }) {
    return VehiclePackPurchaseState(
      entitlement: entitlement ?? this.entitlement,
      status: status ?? this.status,
      productDetails: productDetails == _productDetailsUnset
          ? this.productDetails
          : productDetails as ProductDetails?,
      errorMessage: errorMessage == _errorMessageUnset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _productDetailsUnset = Object();
const Object _errorMessageUnset = Object();

class VehiclePackPurchaseController extends ChangeNotifier {
  VehiclePackPurchaseController({
    required IapPurchaseClient purchaseClient,
    required LocalPurchaseEntitlementStore entitlementStore,
    PurchaseEntitlement initialEntitlement = const PurchaseEntitlement.locked(),
    DateTime Function()? now,
  }) : _purchaseClient = purchaseClient,
       _entitlementStore = entitlementStore,
       _now = now ?? DateTime.now,
       _state = VehiclePackPurchaseState(entitlement: initialEntitlement);

  final IapPurchaseClient _purchaseClient;
  final LocalPurchaseEntitlementStore _entitlementStore;
  final DateTime Function() _now;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  VehiclePackPurchaseState _state;

  VehiclePackPurchaseState get state => _state;
  PurchaseEntitlement get entitlement => _state.entitlement;
  bool get isListening => _purchaseSubscription != null;

  void startListening() {
    if (_purchaseSubscription != null) {
      return;
    }

    _purchaseSubscription = _purchaseClient.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.error,
            errorMessage: error.toString(),
          ),
        );
      },
    );
  }

  Future<void> loadProductDetails() async {
    _setState(
      _state.copyWith(
        status: VehiclePackPurchaseStatus.loadingProduct,
        errorMessage: null,
      ),
    );

    try {
      final isAvailable = await _purchaseClient.isAvailable();
      if (!isAvailable) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.storeUnavailable,
            productDetails: null,
          ),
        );
        return;
      }

      final response = await _purchaseClient.queryProductDetails(
        IapProductIds.all,
      );
      if (response.error != null) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.error,
            errorMessage: response.error.toString(),
          ),
        );
        return;
      }

      final productDetails = _vehiclePackProductDetails(
        response.productDetails,
      );
      if (productDetails == null) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.productNotFound,
            productDetails: null,
          ),
        );
        return;
      }

      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.productReady,
          productDetails: productDetails,
        ),
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<bool> buyVehiclePack({String? applicationUserName}) async {
    var productDetails = _state.productDetails;
    if (productDetails == null) {
      await loadProductDetails();
      productDetails = _state.productDetails;
    }
    if (productDetails == null) {
      return false;
    }

    try {
      return await _purchaseClient.buyNonConsumable(
        productDetails: productDetails,
        applicationUserName: applicationUserName,
      );
    } catch (error) {
      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.error,
          errorMessage: error.toString(),
        ),
      );
      return false;
    }
  }

  Future<void> restorePurchases({String? applicationUserName}) async {
    _setState(
      _state.copyWith(
        status: VehiclePackPurchaseStatus.restoring,
        errorMessage: null,
      ),
    );

    try {
      await _purchaseClient.restorePurchases(
        applicationUserName: applicationUserName,
      );
      if (_state.status == VehiclePackPurchaseStatus.restoring &&
          !_state.vehiclePackUnlocked) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.restoreNotFound,
            errorMessage: null,
          ),
        );
      }
    } catch (error) {
      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != IapProductIds.vehiclePack) {
        continue;
      }

      await _handlePurchaseUpdate(purchase);
    }
  }

  Future<void> _handlePurchaseUpdate(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.purchasePending,
            errorMessage: null,
          ),
        );
      case PurchaseStatus.purchased:
        await _unlockFromPurchase(
          purchase,
          status: VehiclePackPurchaseStatus.purchaseCompleted,
          source: 'purchase',
        );
      case PurchaseStatus.restored:
        await _unlockFromPurchase(
          purchase,
          status: VehiclePackPurchaseStatus.restoreCompleted,
          source: 'restore',
        );
      case PurchaseStatus.error:
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.error,
            errorMessage: purchase.error?.message ?? 'Purchase failed.',
          ),
        );
        await _completeTerminalPurchaseIfNeeded(purchase);
      case PurchaseStatus.canceled:
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.canceled,
            errorMessage: null,
          ),
        );
        await _completeTerminalPurchaseIfNeeded(purchase);
    }
  }

  Future<void> _unlockFromPurchase(
    PurchaseDetails purchase, {
    required VehiclePackPurchaseStatus status,
    required String source,
  }) async {
    final entitlement = PurchaseEntitlement(
      vehiclePackUnlocked: true,
      productId: purchase.productID,
      purchasedAt: _purchaseDate(purchase) ?? _now(),
      lastUpdatedAt: _now(),
      source: source,
      transactionId: purchase.purchaseID,
    );

    try {
      await _entitlementStore.save(entitlement);
    } catch (error) {
      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.error,
          errorMessage: error.toString(),
        ),
      );
      return;
    }

    _setState(
      _state.copyWith(
        entitlement: entitlement,
        status: status,
        errorMessage: null,
      ),
    );
    await _completeTerminalPurchaseIfNeeded(purchase);
  }

  Future<void> _completeTerminalPurchaseIfNeeded(
    PurchaseDetails purchase,
  ) async {
    if (!purchase.pendingCompletePurchase) {
      return;
    }

    try {
      await _purchaseClient.completePurchase(purchase);
    } catch (error) {
      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  ProductDetails? _vehiclePackProductDetails(List<ProductDetails> products) {
    for (final product in products) {
      if (product.id == IapProductIds.vehiclePack) {
        return product;
      }
    }

    return null;
  }

  DateTime? _purchaseDate(PurchaseDetails purchase) {
    final transactionDate = purchase.transactionDate;
    if (transactionDate == null || transactionDate.trim().isEmpty) {
      return null;
    }

    final millisecondsSinceEpoch = int.tryParse(transactionDate);
    if (millisecondsSinceEpoch == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch,
      isUtc: true,
    );
  }

  void _setState(VehiclePackPurchaseState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
