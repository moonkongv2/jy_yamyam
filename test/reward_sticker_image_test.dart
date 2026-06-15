import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/models/reward_item.dart';
import 'package:jy_yamyam/theme/app_colors.dart';
import 'package:jy_yamyam/widgets/reward_sticker_image.dart';

void main() {
  testWidgets('Unlocked reward sticker uses the original image colors', (
    tester,
  ) async {
    final reward = RewardCatalog.findVehicleStickerByVehicleId('motorcycle')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: RewardStickerImage(reward: reward, size: 72)),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));

    expect(image.color, isNull);
    expect(image.colorBlendMode, isNull);
    expect(find.byType(Opacity), findsNothing);
    expect(find.byType(ColorFiltered), findsNothing);
  });

  testWidgets(
    'Unframed reward sticker renders artwork without the sticker frame',
    (tester) async {
      final reward = RewardCatalog.findVehicleStickerByVehicleId('motorcycle')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: RewardStickerImage(reward: reward, size: 132, framed: false),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));

      expect(image.width, 132);
      expect(image.height, 132);
      expect(find.byType(DecoratedBox), findsNothing);
    },
  );

  testWidgets('Locked reward sticker silhouettes the image only', (
    tester,
  ) async {
    final reward = RewardCatalog.findVehicleStickerByVehicleId('motorcycle')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RewardStickerImage(reward: reward, size: 72, locked: true),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final opacity = tester.widget<Opacity>(find.byType(Opacity));
    final frame = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final decoration = frame.decoration as BoxDecoration;

    expect(image.color, AppColors.textSecondary);
    expect(image.colorBlendMode, BlendMode.srcIn);
    expect(opacity.opacity, 0.58);
    expect(decoration.color, AppColors.white);
    expect(find.byType(ColorFiltered), findsNothing);
  });
}
