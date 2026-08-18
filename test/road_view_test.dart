import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jy_yamyam/catalogs/meal_ingredient_catalog.dart';
import 'package:jy_yamyam/catalogs/motivation_asset_catalog.dart';
import 'package:jy_yamyam/catalogs/vehicle_catalog.dart';
import 'package:jy_yamyam/l10n/app_texts.dart';
import 'package:jy_yamyam/models/meal_timer_config.dart';
import 'package:jy_yamyam/models/vehicle.dart';
import 'package:jy_yamyam/models/vehicle_avatar_presentation.dart';
import 'package:jy_yamyam/widgets/goal_star_pulse.dart';
import 'package:jy_yamyam/widgets/road_painter.dart';
import 'package:jy_yamyam/widgets/road_view.dart';
import 'package:jy_yamyam/widgets/vehicle_widget.dart';

import 'helpers/test_image_fixture.dart';

void main() {
  testWidgets('Road view shows winding route markers and vehicle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(progress: 0.5, vehicle: VehicleCatalog.fireTruck),
          ),
        ),
      ),
    );

    expect(find.byType(VehicleWidget), findsOneWidget);
    expect(tester.widget<VehicleWidget>(find.byType(VehicleWidget)).angle, 0);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.byIcon(Icons.restaurant_rounded), findsNothing);
    expect(find.byIcon(Icons.emoji_events_rounded), findsNothing);
    expect(find.byIcon(Icons.flag_rounded), findsNothing);
    expect(find.byType(GoalStarPulse), findsOneWidget);

    const roadSize = Size(420, 640);
    final roadBounds = createRoadBounds(roadSize);
    final roadSides = [
      for (var index = 0; index <= 20; index += 1)
        roadPointForProgress(roadSize, index / 20).dx < roadBounds.center.dx,
    ];
    var sideChanges = 0;
    for (var index = 1; index < roadSides.length; index += 1) {
      if (roadSides[index] != roadSides[index - 1]) {
        sideChanges += 1;
      }
    }
    expect(sideChanges, greaterThanOrEqualTo(7));
    expect(
      roadPointForProgress(roadSize, 1).dx,
      lessThan(roadBounds.center.dx),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(progress: 0.15, vehicle: VehicleCatalog.fireTruck),
          ),
        ),
      ),
    );
    expect(
      tester.widget<VehicleWidget>(find.byType(VehicleWidget)).isFacingLeft,
      isTrue,
    );
  });

  testWidgets('Road view anchors finish star near the route endpoint', (
    tester,
  ) async {
    Future<void> expectStarNearEndpoint({
      required Size roadSize,
      required Duration courseDuration,
      required double cameraProgress,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: roadSize.width,
              height: roadSize.height,
              child: RoadView(
                cameraProgress: cameraProgress,
                vehicleProgress: 0.35,
                vehicle: VehicleCatalog.fireTruck,
                showVehicle: false,
                courseDuration: courseDuration,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final roadRect = tester.getRect(find.byType(RoadView));
      final geometry = createRoadCourseGeometry(
        viewportSize: roadRect.size,
        duration: courseDuration,
      );
      final cameraOffsetY = roadCameraOffsetForGeometryProgress(
        geometry: geometry,
        progress: cameraProgress,
      );
      final starCenter =
          tester.getCenter(find.byType(GoalStarPulse)) -
          roadRect.topLeft +
          Offset(0, cameraOffsetY);
      final starRect = tester.getRect(find.byType(GoalStarPulse));
      final endpoint = roadPointForGeometryProgress(geometry, 1);
      final endpointInViewport =
          roadRect.topLeft + endpoint - Offset(0, cameraOffsetY);
      final starSize = roadRect.width > roadRect.height ? 68.0 : 56.0;
      final expectedStarCenter = endpoint - Offset(0, starSize * 0.08);

      expect((starCenter - expectedStarCenter).distance, lessThan(1));
      expect(starRect.inflate(2).contains(endpointInViewport), isTrue);
    }

    await expectStarNearEndpoint(
      roadSize: const Size(420, 640),
      courseDuration: const Duration(minutes: 5),
      cameraProgress: 0,
    );
    await expectStarNearEndpoint(
      roadSize: const Size(800, 400),
      courseDuration: const Duration(minutes: 5),
      cameraProgress: 0,
    );
    await expectStarNearEndpoint(
      roadSize: const Size(420, 640),
      courseDuration: const Duration(minutes: 60),
      cameraProgress: 1,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Road view passes each vehicle course kind to the road painter', (
    tester,
  ) async {
    Future<RoadPainter> pumpRoadPainterForVehicle(
      VehicleDefinition vehicle,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 640,
              child: RoadView(progress: 0.5, vehicle: vehicle),
            ),
          ),
        ),
      );

      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((widget) => widget.painter)
          .whereType<RoadPainter>();
      expect(painters, isNotEmpty, reason: vehicle.id);
      return painters.single;
    }

    final roadPainter = await pumpRoadPainterForVehicle(
      VehicleCatalog.fireTruck,
    );
    expect(roadPainter.courseKind, VehicleCourseKind.road);

    final skyPainter = await pumpRoadPainterForVehicle(VehicleCatalog.airplane);
    expect(skyPainter.courseKind, VehicleCourseKind.sky);

    final waterPainter = await pumpRoadPainterForVehicle(VehicleCatalog.shark);
    expect(waterPainter.courseKind, VehicleCourseKind.water);

    final railPainter = await pumpRoadPainterForVehicle(VehicleCatalog.train);
    expect(railPainter.courseKind, VehicleCourseKind.rail);

    final fieldPainter = await pumpRoadPainterForVehicle(VehicleCatalog.tRex);
    expect(fieldPainter.courseKind, VehicleCourseKind.field);
  });

  testWidgets('Road view keeps vehicle inside portrait bounds at route ends', (
    tester,
  ) async {
    Future<void> pumpRoad(double progress) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 640,
              child: RoadView(
                progress: progress,
                vehicle: VehicleCatalog.fireTruck,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpRoad(0);
    var roadRect = tester.getRect(find.byType(RoadView));
    var vehicleRect = tester.getRect(find.byType(VehicleWidget));
    expect(vehicleRect.left, greaterThanOrEqualTo(roadRect.left));
    expect(vehicleRect.top, greaterThanOrEqualTo(roadRect.top));
    expect(vehicleRect.right, lessThanOrEqualTo(roadRect.right));
    expect(vehicleRect.bottom, lessThanOrEqualTo(roadRect.bottom));

    await pumpRoad(1);
    roadRect = tester.getRect(find.byType(RoadView));
    vehicleRect = tester.getRect(find.byType(VehicleWidget));
    expect(vehicleRect.left, greaterThanOrEqualTo(roadRect.left));
    expect(vehicleRect.top, greaterThanOrEqualTo(roadRect.top));
    expect(vehicleRect.right, lessThanOrEqualTo(roadRect.right));
    expect(vehicleRect.bottom, lessThanOrEqualTo(roadRect.bottom));
  });

  testWidgets(
    'Road view applies portrait road anchor offset for long vehicles',
    (tester) async {
      const progress = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 640,
              child: RoadView(progress: progress, vehicle: VehicleCatalog.tRex),
            ),
          ),
        ),
      );
      await tester.pump();

      final roadSize = tester.getSize(find.byType(RoadView));
      final vehicleSize = tester.getSize(find.byType(VehicleWidget)).height;
      final rawRoadPoint = roadPointForProgress(roadSize, progress);
      final expectedVehicleCenterY =
          rawRoadPoint.dy +
          (vehicleSize * VehicleCatalog.tRex.roadAnchorOffset.portraitDyRatio);

      expect(vehicleSize, closeTo(120, 0.1));
      expect(
        tester.getCenter(find.byType(VehicleWidget)).dy,
        closeTo(expectedVehicleCenterY, 1),
      );
    },
  );

  testWidgets('RoadView with 30 ingredients renders 30 ingredient markers', (
    tester,
  ) async {
    final ingredients = MealIngredientCatalog.courseSlotsFor(['carrot', 'egg']);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(
              progress: 0,
              vehicle: VehicleCatalog.fireTruck,
              ingredients: ingredients,
            ),
          ),
        ),
      ),
    );

    for (var index = 0; index < ingredients.length; index += 1) {
      expect(
        find.byKey(ValueKey('roadIngredientMarker_$index')),
        findsOneWidget,
      );
    }
  });

  testWidgets('RoadView keeps dense ingredient markers clear of finish star', (
    tester,
  ) async {
    final ingredients = MealIngredientCatalog.courseSlotsFor(['carrot', 'egg']);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(
              progress: 0,
              vehicle: VehicleCatalog.fireTruck,
              showVehicle: false,
              ingredients: ingredients,
              ingredientClearProgress: 0,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final starRect = tester.getRect(find.byType(GoalStarPulse));
    for (var index = 0; index < ingredients.length; index += 1) {
      final ingredientRect = tester.getRect(
        find.byKey(ValueKey('roadIngredientMarker_$index')),
      );
      expect(ingredientRect.overlaps(starRect), isFalse);
    }
  });

  testWidgets('RoadView at progress 1 hides ingredient markers', (
    tester,
  ) async {
    final ingredients = MealIngredientCatalog.courseSlotsFor(['carrot', 'egg']);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(
              progress: 0,
              vehicle: VehicleCatalog.fireTruck,
              ingredients: ingredients,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('roadIngredientMarker_0')),
      findsOneWidget,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(
              progress: 1,
              vehicle: VehicleCatalog.fireTruck,
              ingredients: ingredients,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var index = 0; index < ingredients.length; index += 1) {
      expect(find.byKey(ValueKey('roadIngredientMarker_$index')), findsNothing);
    }
  });

  testWidgets('RoadView keeps long-course vehicle inside viewport', (
    tester,
  ) async {
    Future<void> pumpLongRoad(double progress) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 640,
              child: RoadView(
                progress: progress,
                vehicle: VehicleCatalog.fireTruck,
                courseDuration: const Duration(minutes: 60),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    for (final progress in const [0.0, 0.5, 1.0]) {
      await pumpLongRoad(progress);

      final roadRect = tester.getRect(find.byType(RoadView));
      final vehicleRect = tester.getRect(find.byType(VehicleWidget));
      expect(vehicleRect.left, greaterThanOrEqualTo(roadRect.left));
      expect(vehicleRect.top, greaterThanOrEqualTo(roadRect.top));
      expect(vehicleRect.right, lessThanOrEqualTo(roadRect.right));
      expect(vehicleRect.bottom, lessThanOrEqualTo(roadRect.bottom));
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets(
    'RoadView keeps long-course ingredient markers in the road layer',
    (tester) async {
      final ingredients = MealIngredientCatalog.courseSlotsFor([
        'carrot',
        'egg',
      ]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 640,
              child: RoadView(
                progress: 0.5,
                vehicle: VehicleCatalog.fireTruck,
                ingredients: ingredients,
                ingredientClearProgress: 0,
                courseDuration: const Duration(minutes: 60),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      for (var index = 0; index < ingredients.length; index += 1) {
        expect(
          find.byKey(ValueKey('roadIngredientMarker_$index')),
          findsOneWidget,
        );
      }

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    },
  );

  testWidgets('Road view renders custom avatar overlay from local file', (
    tester,
  ) async {
    final avatarFile = createTemporaryAvatarImage();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(
              progress: 0.5,
              vehicle: VehicleCatalog.fireTruck,
              avatar: VehicleAvatarPresentation(
                mode: AvatarImageMode.custom,
                imagePath: avatarFile.path,
                scale: 1.2,
                offsetX: 0.05,
                offsetY: -0.04,
                rotationDegrees: 6,
              ),
              avatarImageBuilder: (context, imagePath) {
                return const ColoredBox(
                  key: ValueKey('avatarCompositeOverlayImage'),
                  color: Colors.pink,
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(VehicleWidget), findsOneWidget);
    expect(
      find.byKey(const ValueKey('avatarCompositeOverlayImage')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Road view ignores missing custom avatar file safely', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 640,
            child: RoadView(
              progress: 0.5,
              vehicle: VehicleCatalog.fireTruck,
              avatar: const VehicleAvatarPresentation(
                mode: AvatarImageMode.custom,
                imagePath: '/missing/avatar.png',
                scale: 1.2,
                offsetX: 0.05,
                offsetY: -0.04,
                rotationDegrees: 6,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(VehicleWidget), findsOneWidget);
    expect(
      find.byKey(const ValueKey('avatarCompositeOverlayImage')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Road view limits motivation video to 16:9 in landscape', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 520,
            child: RoadView(
              progress: 0.5,
              vehicle: VehicleCatalog.fireTruck,
              motivationVideoAssetPath:
                  MotivationAssetCatalog.fallbackVideoPath,
              motivationVideoMilestone: 10,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final videoSize = tester.getSize(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
    );
    expect(videoSize.width, lessThanOrEqualTo(460));
    expect(videoSize.width / videoSize.height, closeTo(16 / 9, 0.01));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 520,
            child: RoadMotivationVideoLayer(
              assetPath: MotivationAssetCatalog.fallbackVideoPath,
              milestone: 10,
              reservedRightInset: 92,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final insetVideoRect = tester.getRect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
    );
    expect(insetVideoRect.right, lessThanOrEqualTo(1200 - 16 - 92));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('RoadView keeps motivation video fixed while long road scrolls', (
    tester,
  ) async {
    Future<void> pumpLongRoadWithVideo(double progress) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: AppTexts.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 420,
              height: 640,
              child: RoadView(
                progress: progress,
                vehicle: VehicleCatalog.fireTruck,
                motivationVideoAssetPath:
                    MotivationAssetCatalog.fallbackVideoPath,
                motivationVideoMilestone: 10,
                courseDuration: const Duration(minutes: 60),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpLongRoadWithVideo(0);
    final startRect = tester.getRect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
    );

    await pumpLongRoadWithVideo(0.5);
    final middleRect = tester.getRect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
    );

    expect(middleRect.left, closeTo(startRect.left, 0.1));
    expect(middleRect.top, closeTo(startRect.top, 0.1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('RoadVehicleLayer keeps long-course vehicle inside viewport', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 520,
            child: RoadVehicleLayer(
              progress: 0.5,
              vehicle: VehicleCatalog.fireTruck,
              courseDuration: const Duration(minutes: 60),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final layerRect = tester.getRect(find.byType(RoadVehicleLayer));
    final vehicleRect = tester.getRect(find.byType(VehicleWidget));
    expect(vehicleRect.left, greaterThanOrEqualTo(layerRect.left));
    expect(vehicleRect.top, greaterThanOrEqualTo(layerRect.top));
    expect(vehicleRect.right, lessThanOrEqualTo(layerRect.right));
    expect(vehicleRect.bottom, lessThanOrEqualTo(layerRect.bottom));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('Motivation video can render as a separate road layer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 520,
            child: RoadView(
              progress: 0.5,
              vehicle: VehicleCatalog.fireTruck,
              motivationVideoAssetPath:
                  MotivationAssetCatalog.fallbackVideoPath,
              motivationVideoMilestone: 10,
              showMotivationVideo: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
      findsNothing,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: AppTexts.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1200,
            height: 520,
            child: RoadMotivationVideoLayer(
              assetPath: MotivationAssetCatalog.fallbackVideoPath,
              milestone: 10,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final videoSize = tester.getSize(
      find.byKey(const ValueKey('motivationVideoBubble_10')),
    );
    expect(videoSize.width, lessThanOrEqualTo(460));
    expect(videoSize.width / videoSize.height, closeTo(16 / 9, 0.01));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
