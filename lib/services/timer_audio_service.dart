import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../catalogs/timer_audio_asset_catalog.dart';

abstract interface class TimerAudioService {
  Future<void> startOrResumeBgm();

  Future<void> pauseBgm();

  Future<void> stopBgm();

  Future<void> playMarkerSfx();

  Future<void> playCourseLoading();

  Future<void> stopCourseLoading();

  Future<void> playReadyStartBeep();

  Future<void> stopReadyStartBeep();

  Future<void> stopAll();

  Future<void> dispose();
}

class NoOpTimerAudioService implements TimerAudioService {
  const NoOpTimerAudioService();

  @override
  Future<void> startOrResumeBgm() async {}

  @override
  Future<void> pauseBgm() async {}

  @override
  Future<void> stopBgm() async {}

  @override
  Future<void> playMarkerSfx() async {}

  @override
  Future<void> playCourseLoading() async {}

  @override
  Future<void> stopCourseLoading() async {}

  @override
  Future<void> playReadyStartBeep() async {}

  @override
  Future<void> stopReadyStartBeep() async {}

  @override
  Future<void> stopAll() async {}

  @override
  Future<void> dispose() async {}
}

class AudioplayersTimerAudioService implements TimerAudioService {
  AudioplayersTimerAudioService({
    String bgmAssetPath = TimerAudioAssetCatalog.bgmAssetPath,
    String markerAssetPath = TimerAudioAssetCatalog.markerAssetPath,
    String courseLoadingAssetPath =
        TimerAudioAssetCatalog.courseLoadingAssetPath,
    String readyStartBeepAssetPath =
        TimerAudioAssetCatalog.readyStartBeepAssetPath,
    double bgmVolume = TimerAudioAssetCatalog.bgmVolume,
    double markerVolume = TimerAudioAssetCatalog.markerVolume,
    double courseLoadingVolume = TimerAudioAssetCatalog.courseLoadingVolume,
    double readyStartBeepVolume = TimerAudioAssetCatalog.readyStartBeepVolume,
  }) : _bgmAssetPath = bgmAssetPath,
       _markerAssetPath = markerAssetPath,
       _courseLoadingAssetPath = courseLoadingAssetPath,
       _readyStartBeepAssetPath = readyStartBeepAssetPath,
       _bgmVolume = bgmVolume,
       _markerVolume = markerVolume,
       _courseLoadingVolume = courseLoadingVolume,
       _readyStartBeepVolume = readyStartBeepVolume,
       _bgmPlayer = AudioPlayer(),
       _markerPlayer = AudioPlayer(),
       _courseLoadingPlayer = AudioPlayer(),
       _readyStartBeepPlayer = AudioPlayer(),
       _audioContext = AudioContextConfig(
         focus: AudioContextConfigFocus.gain,
         respectSilence: false,
       ).build();

  final String _bgmAssetPath;
  final String _markerAssetPath;
  final String _courseLoadingAssetPath;
  final String _readyStartBeepAssetPath;
  final double _bgmVolume;
  final double _markerVolume;
  final double _courseLoadingVolume;
  final double _readyStartBeepVolume;
  final AudioPlayer _bgmPlayer;
  final AudioPlayer _markerPlayer;
  final AudioPlayer _courseLoadingPlayer;
  final AudioPlayer _readyStartBeepPlayer;
  final AudioContext _audioContext;

  Future<void>? _bgmTransition;
  var _bgmPrepared = false;
  var _bgmPlaying = false;
  var _disposed = false;

  @override
  Future<void> startOrResumeBgm() {
    return _enqueueBgmTransition(() async {
      if (_disposed || _bgmPlaying) {
        return;
      }

      if (_bgmPrepared) {
        await _bgmPlayer.resume();
      } else {
        await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
        await _bgmPlayer.play(
          AssetSource(_assetSourcePath(_bgmAssetPath)),
          volume: _bgmVolume,
          ctx: _audioContext,
          mode: PlayerMode.mediaPlayer,
        );
        _bgmPrepared = true;
      }
      _bgmPlaying = true;
    }, 'Timer BGM start/resume failed');
  }

  @override
  Future<void> pauseBgm() {
    return _enqueueBgmTransition(() async {
      if (_disposed || !_bgmPlaying) {
        return;
      }
      await _bgmPlayer.pause();
      _bgmPlaying = false;
    }, 'Timer BGM pause failed');
  }

  @override
  Future<void> stopBgm() {
    return _enqueueBgmTransition(() async {
      if (_disposed || (!_bgmPrepared && !_bgmPlaying)) {
        return;
      }
      await _bgmPlayer.stop();
      _bgmPrepared = false;
      _bgmPlaying = false;
    }, 'Timer BGM stop failed');
  }

  @override
  Future<void> playMarkerSfx() async {
    if (_disposed) {
      return;
    }

    try {
      await _markerPlayer.setReleaseMode(ReleaseMode.stop);
      await _markerPlayer.play(
        AssetSource(_assetSourcePath(_markerAssetPath)),
        volume: _markerVolume,
        ctx: _audioContext,
        mode: PlayerMode.lowLatency,
      );
    } catch (error, stackTrace) {
      debugPrint('Timer marker SFX playback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> playCourseLoading() async {
    if (_disposed) {
      return;
    }

    try {
      await _courseLoadingPlayer.setReleaseMode(ReleaseMode.stop);
      await _courseLoadingPlayer.play(
        AssetSource(_assetSourcePath(_courseLoadingAssetPath)),
        volume: _courseLoadingVolume,
        ctx: _audioContext,
        mode: PlayerMode.mediaPlayer,
      );
    } catch (error, stackTrace) {
      debugPrint('Timer course loading playback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> stopCourseLoading() async {
    if (_disposed) {
      return;
    }

    try {
      await _courseLoadingPlayer.stop();
    } catch (error, stackTrace) {
      debugPrint('Timer course loading stop failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> playReadyStartBeep() async {
    if (_disposed) {
      return;
    }

    try {
      await _readyStartBeepPlayer.setReleaseMode(ReleaseMode.stop);
      await _readyStartBeepPlayer.play(
        AssetSource(_assetSourcePath(_readyStartBeepAssetPath)),
        volume: _readyStartBeepVolume,
        ctx: _audioContext,
        mode: PlayerMode.lowLatency,
      );
    } catch (error, stackTrace) {
      debugPrint('Timer ready/start beep playback failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> stopReadyStartBeep() async {
    if (_disposed) {
      return;
    }

    try {
      await _readyStartBeepPlayer.stop();
    } catch (error, stackTrace) {
      debugPrint('Timer ready/start beep stop failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Future<void> stopAll() async {
    await stopBgm();
    if (_disposed) {
      return;
    }

    try {
      await _markerPlayer.stop();
    } catch (error, stackTrace) {
      debugPrint('Timer marker SFX stop failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    await stopCourseLoading();
    await stopReadyStartBeep();
  }

  @override
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }

    await stopAll();
    _disposed = true;
    await Future.wait([
      _disposePlayer(_bgmPlayer, 'Timer BGM dispose failed'),
      _disposePlayer(_markerPlayer, 'Timer marker SFX dispose failed'),
      _disposePlayer(
        _courseLoadingPlayer,
        'Timer course loading dispose failed',
      ),
      _disposePlayer(
        _readyStartBeepPlayer,
        'Timer ready/start beep dispose failed',
      ),
    ]);
  }

  Future<void> _enqueueBgmTransition(
    Future<void> Function() transition,
    String errorMessage,
  ) {
    final nextTransition = (_bgmTransition ?? Future<void>.value()).then((
      _,
    ) async {
      try {
        await transition();
      } catch (error, stackTrace) {
        debugPrint('$errorMessage: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    });
    _bgmTransition = nextTransition;
    return nextTransition;
  }

  Future<void> _disposePlayer(AudioPlayer player, String errorMessage) async {
    try {
      await player.dispose();
    } catch (error, stackTrace) {
      debugPrint('$errorMessage: $error');
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
