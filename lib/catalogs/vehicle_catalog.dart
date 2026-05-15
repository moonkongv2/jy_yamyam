import '../models/vehicle.dart';

abstract final class VehicleCatalog {
  // Avatar slots are placeholders and need visual tuning against the real assets.
  static const motorcycle = VehicleDefinition(
    id: 'motorcycle',
    labelKo: '오토바이',
    labelEn: 'Motorcycle',
    emoji: '🏍️',
    assetPath: 'assets/images/vehicle_motorcycle.png',
    selectionAssetPath: 'assets/images/vehicle_motorcycle_chip.png',
    avatarSlot: VehicleAvatarSlot(
      centerX: 0.57,
      centerY: 0.31,
      sizeRatio: 0.28,
    ),
  );

  static const fireTruck = VehicleDefinition(
    id: 'fire_truck',
    labelKo: '소방차',
    labelEn: 'Fire truck',
    emoji: '🚒',
    assetPath: 'assets/images/vehicle_fire_truck.png',
    selectionAssetPath: 'assets/images/vehicle_fire_truck_chip.png',
    avatarSlot: VehicleAvatarSlot(
      centerX: 0.57,
      centerY: 0.30,
      sizeRatio: 0.26,
    ),
  );

  static const policeCar = VehicleDefinition(
    id: 'police_car',
    labelKo: '경찰차',
    labelEn: 'Police car',
    emoji: '🚓',
    assetPath: 'assets/images/vehicle_police_car.png',
    selectionAssetPath: 'assets/images/vehicle_police_car_chip.png',
    avatarSlot: VehicleAvatarSlot(
      centerX: 0.57,
      centerY: 0.30,
      sizeRatio: 0.26,
    ),
  );

  static const excavator = VehicleDefinition(
    id: 'excavator',
    labelKo: '포크레인',
    labelEn: 'Excavator',
    emoji: '🚜',
    assetPath: 'assets/images/vehicle_excavator.png',
    selectionAssetPath: 'assets/images/vehicle_excavator_chip.png',
    avatarSlot: VehicleAvatarSlot(
      centerX: 0.48,
      centerY: 0.28,
      sizeRatio: 0.28,
    ),
  );

  static const all = [motorcycle, fireTruck, policeCar, excavator];

  static VehicleDefinition findById(String id) {
    for (final vehicle in all) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }
    return motorcycle;
  }
}
