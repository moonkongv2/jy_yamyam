import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/models/reward_item.dart';

void main() {
  test('Reward catalog generates one sticker for every vehicle', () {
    expect(RewardCatalog.all, hasLength(VehicleCatalog.all.length));
    expect(RewardCatalog.all.map((reward) => reward.vehicleId).take(2), [
      'motorcycle',
      'supercar',
    ]);

    for (final vehicle in VehicleCatalog.all) {
      final sticker = RewardCatalog.findVehicleStickerByVehicleId(vehicle.id);

      expect(sticker, isNotNull, reason: vehicle.id);
      expect(
        sticker?.id,
        RewardCatalog.vehicleStickerIdForVehicle(vehicle.id),
        reason: vehicle.id,
      );
      expect(sticker?.id, 'sticker_vehicle_${vehicle.id}', reason: vehicle.id);
      expect(sticker?.imageAssetPath, vehicle.assetPath, reason: vehicle.id);
      expect(sticker?.vehicleId, vehicle.id, reason: vehicle.id);
    }
  });

  test('Reward catalog finds generated vehicle stickers safely', () {
    for (final vehicle in VehicleCatalog.all) {
      final stickerId = RewardCatalog.vehicleStickerIdForVehicle(vehicle.id);
      final stickerById = RewardCatalog.findById(stickerId);
      final stickerByVehicle = RewardCatalog.findVehicleStickerByVehicleId(
        vehicle.id,
      );

      expect(stickerById, isNotNull, reason: vehicle.id);
      expect(stickerById, same(stickerByVehicle), reason: vehicle.id);
    }

    expect(
      RewardCatalog.findVehicleStickerByVehicleId('missing_vehicle'),
      isNull,
    );
    expect(RewardCatalog.findById('sticker_vehicle_missing_vehicle'), isNull);
  });
}
