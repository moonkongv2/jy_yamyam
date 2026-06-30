import 'package:shared_preferences/shared_preferences.dart';

import '../models/purchase_entitlement.dart';

class LocalPurchaseEntitlementStore {
  const LocalPurchaseEntitlementStore();

  static const _vehiclePackUnlockedKey = 'purchase.vehiclePackUnlocked';
  static const _productIdKey = 'purchase.vehiclePackProductId';
  static const _purchasedAtKey = 'purchase.vehiclePackPurchasedAt';
  static const _lastUpdatedAtKey = 'purchase.vehiclePackLastUpdatedAt';
  static const _sourceKey = 'purchase.vehiclePackSource';
  static const _transactionIdKey = 'purchase.vehiclePackTransactionId';

  Future<PurchaseEntitlement> load() async {
    final preferences = await SharedPreferences.getInstance();
    final vehiclePackUnlocked =
        preferences.getBool(_vehiclePackUnlockedKey) ?? false;

    if (!vehiclePackUnlocked) {
      return const PurchaseEntitlement.locked();
    }

    return PurchaseEntitlement(
      vehiclePackUnlocked: true,
      productId: _stringPreference(preferences, _productIdKey),
      purchasedAt: _dateTimePreference(preferences, _purchasedAtKey),
      lastUpdatedAt: _dateTimePreference(preferences, _lastUpdatedAtKey),
      source: _stringPreference(preferences, _sourceKey),
      transactionId: _stringPreference(preferences, _transactionIdKey),
    );
  }

  Future<void> save(PurchaseEntitlement entitlement) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      _vehiclePackUnlockedKey,
      entitlement.vehiclePackUnlocked,
    );

    if (!entitlement.vehiclePackUnlocked) {
      await _removeMetadata(preferences);
      return;
    }

    await _setOptionalString(preferences, _productIdKey, entitlement.productId);
    await _setOptionalDateTime(
      preferences,
      _purchasedAtKey,
      entitlement.purchasedAt,
    );
    await _setOptionalDateTime(
      preferences,
      _lastUpdatedAtKey,
      entitlement.lastUpdatedAt,
    );
    await _setOptionalString(preferences, _sourceKey, entitlement.source);
    await _setOptionalString(
      preferences,
      _transactionIdKey,
      entitlement.transactionId,
    );
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_vehiclePackUnlockedKey);
    await _removeMetadata(preferences);
  }

  Future<void> _removeMetadata(SharedPreferences preferences) async {
    await preferences.remove(_productIdKey);
    await preferences.remove(_purchasedAtKey);
    await preferences.remove(_lastUpdatedAtKey);
    await preferences.remove(_sourceKey);
    await preferences.remove(_transactionIdKey);
  }

  String? _stringPreference(SharedPreferences preferences, String key) {
    final value = preferences.getString(key)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  DateTime? _dateTimePreference(SharedPreferences preferences, String key) {
    final value = preferences.getString(key)?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }

  Future<void> _setOptionalString(
    SharedPreferences preferences,
    String key,
    String? value,
  ) async {
    final normalizedValue = value?.trim();
    if (normalizedValue == null || normalizedValue.isEmpty) {
      await preferences.remove(key);
      return;
    }

    await preferences.setString(key, normalizedValue);
  }

  Future<void> _setOptionalDateTime(
    SharedPreferences preferences,
    String key,
    DateTime? value,
  ) async {
    if (value == null) {
      await preferences.remove(key);
      return;
    }

    await preferences.setString(key, value.toIso8601String());
  }
}
