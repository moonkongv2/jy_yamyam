import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jy_yamyam/catalogs/result_audio_asset_catalog.dart';
import 'package:jy_yamyam/catalogs/timer_audio_asset_catalog.dart';

void main() {
  test('timer audio catalog paths are registered exact runtime assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final bgmAssetPath = TimerAudioAssetCatalog.bgmAssetPath;
    final markerAssetPath = TimerAudioAssetCatalog.markerAssetPath;
    final courseLoadingAssetPath =
        TimerAudioAssetCatalog.courseLoadingAssetPath;
    final readyStartBeepAssetPath =
        TimerAudioAssetCatalog.readyStartBeepAssetPath;
    final finishDriveShortAssetPath =
        TimerAudioAssetCatalog.finishDriveShortAssetPath;
    final finishDriveLongAssetPath =
        TimerAudioAssetCatalog.finishDriveLongAssetPath;
    final finishArrivalAssetPath =
        TimerAudioAssetCatalog.finishArrivalAssetPath;

    expect(File(bgmAssetPath).existsSync(), isTrue);
    expect(File(markerAssetPath).existsSync(), isTrue);
    expect(File(courseLoadingAssetPath).existsSync(), isTrue);
    expect(File(readyStartBeepAssetPath).existsSync(), isTrue);
    expect(File(finishDriveShortAssetPath).existsSync(), isTrue);
    expect(File(finishDriveLongAssetPath).existsSync(), isTrue);
    expect(File(finishArrivalAssetPath).existsSync(), isTrue);
    expect(pubspec, contains('    - $bgmAssetPath\n'));
    expect(pubspec, contains('    - $markerAssetPath\n'));
    expect(pubspec, contains('    - $courseLoadingAssetPath\n'));
    expect(pubspec, contains('    - $readyStartBeepAssetPath\n'));
    expect(pubspec, contains('    - $finishDriveShortAssetPath\n'));
    expect(pubspec, contains('    - $finishDriveLongAssetPath\n'));
    expect(pubspec, contains('    - $finishArrivalAssetPath\n'));
    expect(pubspec, isNot(contains('    - assets/audio/timer_bgm/\n')));
    expect(pubspec, isNot(contains('    - assets/audio/marker/\n')));
    expect(pubspec, isNot(contains('_licenses')));
  });

  test('result audio catalog paths are registered exact runtime assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final crowdCheeringAssetPath =
        ResultAudioAssetCatalog.crowdCheeringAssetPath;
    final stickerCollectAssetPath =
        ResultAudioAssetCatalog.stickerCollectAssetPath;

    expect(File(crowdCheeringAssetPath).existsSync(), isTrue);
    expect(File(stickerCollectAssetPath).existsSync(), isTrue);
    expect(pubspec, contains('    - $crowdCheeringAssetPath\n'));
    expect(pubspec, contains('    - $stickerCollectAssetPath\n'));
  });

  test('timer audio metadata points at catalog runtime assets', () {
    _expectMetadataMatchesAsset(
      assetPath: TimerAudioAssetCatalog.bgmAssetPath,
      metadataPath:
          'assets/audio/timer_bgm/_licenses/timer_bgm_01/metadata.yaml',
      expectedPurpose: 'timer_background_music',
    );
    _expectMetadataMatchesAsset(
      assetPath: TimerAudioAssetCatalog.markerAssetPath,
      metadataPath: 'assets/audio/marker/_licenses/marker_01/metadata.yaml',
      expectedPurpose: 'course_marker_sound',
    );
  });
}

void _expectMetadataMatchesAsset({
  required String assetPath,
  required String metadataPath,
  required String expectedPurpose,
}) {
  final metadataFile = File(metadataPath);
  final appFilename = assetPath.split('/').last;

  expect(metadataFile.existsSync(), isTrue);
  final metadata = metadataFile.readAsStringSync();

  expect(metadata, contains('app_asset_path: $assetPath'));
  expect(metadata, contains('purpose: $expectedPurpose'));
  expect(metadata, contains('app_filename: $appFilename'));
}
