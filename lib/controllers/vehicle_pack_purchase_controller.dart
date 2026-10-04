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
  Future<void> _purchaseQueue = Future<void>.value();
  Future<void>? _productLoad;
  bool _disposed = false;
  bool _requestInFlight = false;
  Completer<void>? _restoreBatch;

  VehiclePackPurchaseState get state => _state;
  PurchaseEntitlement get entitlement => _state.entitlement;
  bool get isListening => _purchaseSubscription != null;

  void startListening() {
    if (_purchaseSubscription != null) {
      return;
    }

    _purchaseSubscription = _purchaseClient.purchaseStream.listen(
      (purchases) {
        final restoreBatch = _restoreBatch;
        unawaited(
          _enqueuePurchases(purchases).then((_) {
            if (restoreBatch != null && !restoreBatch.isCompleted) {
              restoreBatch.complete();
            }
          }),
        );
      },
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

  Future<void> loadProductDetails({bool preserveStatusOnSuccess = false}) {
    return _productLoad ??= _loadProductDetails(
      preserveStatusOnSuccess: preserveStatusOnSuccess,
    ).whenComplete(() => _productLoad = null);
  }

  Future<void> _loadProductDetails({
    required bool preserveStatusOnSuccess,
  }) async {
    final preservedStatus = preserveStatusOnSuccess ? _state.status : null;
    if (!preserveStatusOnSuccess) {
      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.loadingProduct,
          errorMessage: null,
        ),
      );
    }

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
          status:
              _state.status == VehiclePackPurchaseStatus.loadingProduct ||
                  _state.status == VehiclePackPurchaseStatus.idle
              ? preservedStatus ?? VehiclePackPurchaseStatus.productReady
              : _state.status,
          productDetails: productDetails,
          errorMessage: null,
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
    if (_disposed ||
        _requestInFlight ||
        _state.vehiclePackUnlocked ||
        _state.isPurchasePending ||
        _state.status == VehiclePackPurchaseStatus.restoring) {
      return false;
    }
    _requestInFlight = true;
    try {
      var productDetails = _state.productDetails;
      if (productDetails == null) {
        await loadProductDetails();
        productDetails = _state.productDetails;
      }
      if (productDetails == null) {
        return false;
      }

      try {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.purchasePending,
            errorMessage: null,
          ),
        );
        final started = await _purchaseClient.buyNonConsumable(
          productDetails: productDetails,
          applicationUserName: applicationUserName,
        );
        if (!started && _state.isPurchasePending) {
          _setState(
            _state.copyWith(
              status: VehiclePackPurchaseStatus.error,
              errorMessage: 'Purchase request was not started.',
            ),
          );
        }
        return started;
      } catch (error) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.error,
            errorMessage: error.toString(),
          ),
        );
        return false;
      }
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> restorePurchases({String? applicationUserName}) async {
    if (_disposed ||
        _requestInFlight ||
        _state.isPurchasePending ||
        _state.status == VehiclePackPurchaseStatus.restoring) {
      return;
    }
    _requestInFlight = true;
    startListening();
    final restoreBatch = Completer<void>();
    _restoreBatch = restoreBatch;
    _setState(
      _state.copyWith(
        status: VehiclePackPurchaseStatus.restoring,
        errorMessage: null,
      ),
    );

    try {
      final restored = await _purchaseClient.restorePurchases(
        applicationUserName: applicationUserName,
      );
      if (restored != null) {
        await _enqueuePurchases(
          restored.map((purchase) {
            if (purchase.status == PurchaseStatus.purchased) {
              purchase.status = PurchaseStatus.restored;
            }
            return purchase;
          }).toList(),
        );
      } else {
        await restoreBatch.future.timeout(const Duration(seconds: 5));
      }
      if (_state.status == VehiclePackPurchaseStatus.restoring &&
          !_state.vehiclePackUnlocked) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.restoreNotFound,
            errorMessage: null,
          ),
        );
        if (!_state.hasProductDetails) {
          await loadProductDetails(preserveStatusOnSuccess: true);
        }
      }
    } catch (error) {
      _setState(
        _state.copyWith(
          status: VehiclePackPurchaseStatus.error,
          errorMessage: error.toString(),
        ),
      );
    } finally {
      _requestInFlight = false;
      if (identical(_restoreBatch, restoreBatch)) _restoreBatch = null;
    }
  }

  Future<void> _enqueuePurchases(List<PurchaseDetails> purchases) {
    return _purchaseQueue = _purchaseQueue.then((_) async {
      if (!_disposed) await _handlePurchaseUpdates(purchases);
    });
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != IapProductIds.vehiclePack) {
        continue;
      }

      if (_disposed) return;
      try {
        await _handlePurchaseUpdate(purchase);
      } catch (error) {
        _setState(
          _state.copyWith(
            status: VehiclePackPurchaseStatus.error,
            errorMessage: error.toString(),
          ),
        );
      }
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
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
