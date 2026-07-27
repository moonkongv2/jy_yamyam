import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../catalogs/result_audio_asset_catalog.dart';

abstract interface class ResultAudioService {
  Future<void> playCrowdCheering();

  Future<void> stop();

  Future<void> dispose();
}

class NoOpResultAudioService implements ResultAudioService {
  const NoOpResultAudioService();

  @override
  Future<void> playCrowdCheering() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class AudioplayersResultAudioService implements ResultAudioService {
  AudioplayersResultAudioService({
    String crowdCheeringAssetPath =
        ResultAudioAssetCatalog.crowdCheeringAssetPath,
    double crowdCheeringVolume = ResultAudioAssetCatalog.crowdCheeringVolume,
  }) : _crowdCheeringAssetPath = crowdCheeringAssetPath,
       _crowdCheeringVolume = crowdCheeringVolume,
       _player = AudioPlayer(),
       _audioContext = AudioContextConfig(
         focus: AudioContextConfigFocus.gain,
         respectSilence: false,
       ).build();

  final String _crowdCheeringAssetPath;
  final double _crowdCheeringVolume;
  final AudioPlayer _player;
  final AudioContext _audioContext;
  var _disposed = false;

  @override
  Future<void> playCrowdCheering() async {
    if (_disposed) {
      return;
    }

    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(
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
  Future<void> stop() async {
    if (_disposed) {
      return;
    }

    try {
      await _player.stop();
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
      await _player.dispose();
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
