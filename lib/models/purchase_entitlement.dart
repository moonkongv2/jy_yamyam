const Object _productIdUnset = Object();
const Object _purchasedAtUnset = Object();
const Object _lastUpdatedAtUnset = Object();
const Object _sourceUnset = Object();
const Object _transactionIdUnset = Object();

class PurchaseEntitlement {
  const PurchaseEntitlement({
    required this.vehiclePackUnlocked,
    this.productId,
    this.purchasedAt,
    this.lastUpdatedAt,
    this.source,
    this.transactionId,
  });

  const PurchaseEntitlement.locked()
    : vehiclePackUnlocked = false,
      productId = null,
      purchasedAt = null,
      lastUpdatedAt = null,
      source = null,
      transactionId = null;

  final bool vehiclePackUnlocked;
  final String? productId;
  final DateTime? purchasedAt;
  final DateTime? lastUpdatedAt;
  final String? source;
  final String? transactionId;

  PurchaseEntitlement copyWith({
    bool? vehiclePackUnlocked,
    Object? productId = _productIdUnset,
    Object? purchasedAt = _purchasedAtUnset,
    Object? lastUpdatedAt = _lastUpdatedAtUnset,
    Object? source = _sourceUnset,
    Object? transactionId = _transactionIdUnset,
  }) {
    return PurchaseEntitlement(
      vehiclePackUnlocked: vehiclePackUnlocked ?? this.vehiclePackUnlocked,
      productId: productId == _productIdUnset
          ? this.productId
          : productId as String?,
      purchasedAt: purchasedAt == _purchasedAtUnset
          ? this.purchasedAt
          : purchasedAt as DateTime?,
      lastUpdatedAt: lastUpdatedAt == _lastUpdatedAtUnset
          ? this.lastUpdatedAt
          : lastUpdatedAt as DateTime?,
      source: source == _sourceUnset ? this.source : source as String?,
      transactionId: transactionId == _transactionIdUnset
          ? this.transactionId
          : transactionId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PurchaseEntitlement &&
        other.vehiclePackUnlocked == vehiclePackUnlocked &&
        other.productId == productId &&
        other.purchasedAt == purchasedAt &&
        other.lastUpdatedAt == lastUpdatedAt &&
        other.source == source &&
        other.transactionId == transactionId;
  }

  @override
  int get hashCode {
    return Object.hash(
      vehiclePackUnlocked,
      productId,
      purchasedAt,
      lastUpdatedAt,
      source,
      transactionId,
    );
  }
}
