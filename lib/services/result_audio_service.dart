import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../catalogs/result_audio_asset_catalog.dart';

abstract interface class ResultAudioService {
  Future<void> playCrowdCheering();

  Future<void> playStickerCollect();

  Future<void> stop();

  Future<void> dispose();
}

class NoOpResultAudioService implements ResultAudioService {
  const NoOpResultAudioService();

  @override
  Future<void> playCrowdCheering() async {}

  @override
  Future<void> playStickerCollect() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class AudioplayersResultAudioService implements ResultAudioService {
  AudioplayersResultAudioService({
    String crowdCheeringAssetPath =
        ResultAudioAssetCatalog.crowdCheeringAssetPath,
    String stickerCollectAssetPath =
        ResultAudioAssetCatalog.stickerCollectAssetPath,
    double crowdCheeringVolume = ResultAudioAssetCatalog.crowdCheeringVolume,
    double stickerCollectVolume = ResultAudioAssetCatalog.stickerCollectVolume,
  }) : _crowdCheeringAssetPath = crowdCheeringAssetPath,
       _stickerCollectAssetPath = stickerCollectAssetPath,
       _crowdCheeringVolume = crowdCheeringVolume,
       _stickerCollectVolume = stickerCollectVolume,
       _crowdCheeringPlayer = AudioPlayer(),
       _stickerCollectPlayer = AudioPlayer(),
       _audioContext = AudioContextConfig(
         focus: AudioContextConfigFocus.gain,
         respectSilence: false,
       ).build();

  final String _crowdCheeringAssetPath;
  final String _stickerCollectAssetPath;
  final double _crowdCheeringVolume;
  final double _stickerCollectVolume;
  final AudioPlayer _crowdCheeringPlayer;
  final AudioPlayer _stickerCollectPlayer;
  final AudioContext _audioContext;
  var _disposed = false;

  @override
  Future<void> playCrowdCheering() async {
    if (_disposed) {
      return;
    }

    try {
      await _crowdCheeringPlayer.setReleaseMode(ReleaseMode.stop);
      await _crowdCheeringPlayer.play(
        AssetSource(_assetSourcePath(_crowdCheeringAssetPath)),
        volume: _crowdCheeringVolume,
        ctx: _audioContext,
        mode: PlayerMode.lowLatency,
      );
    } catch (error, stackTrace) {
      debugPrint('Result crowd cheering playback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> playStickerCollect() async {
    if (_disposed) {
      return;
    }

    try {
      await _stickerCollectPlayer.setReleaseMode(ReleaseMode.stop);
      await _stickerCollectPlayer.play(
        AssetSource(_assetSourcePath(_stickerCollectAssetPath)),
        volume: _stickerCollectVolume,
        ctx: _audioContext,
        mode: PlayerMode.lowLatency,
      );
    } catch (error, stackTrace) {
      debugPrint('Result sticker collect playback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> stop() async {
    if (_disposed) {
      return;
    }

    try {
      await _crowdCheeringPlayer.stop();
      await _stickerCollectPlayer.stop();
    } catch (error, stackTrace) {
      debugPrint('Result audio stop failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    await stop();
    _disposed = true;
    try {
      await Future.wait([
        _crowdCheeringPlayer.dispose(),
        _stickerCollectPlayer.dispose(),
      ]);
    } catch (error, stackTrace) {
      debugPrint('Result audio dispose failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

String _assetSourcePath(String assetPath) {
  const assetPrefix = 'assets/';
  return assetPath.startsWith(assetPrefix)
      ? assetPath.substring(assetPrefix.length)
      : assetPath;
}
