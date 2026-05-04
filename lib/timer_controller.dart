import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

enum TimerState { idle, running, paused, completed }

class TimerController {
  ValueNotifier<int> notifier = ValueNotifier(0);
  ValueNotifier<TimerState> timerState = ValueNotifier(TimerState.idle);
  final AudioPlayer _audioPlayer = AudioPlayer();
  late int _initialDuration;
  Timer? _timer;

  void _startTicking(int seconds) {
    // Begin timer countdown
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      notifier.value = notifier.value - 1;
      if (notifier.value <= 0) {
        timer.cancel();
        _audioPlayer.setReleaseMode(ReleaseMode.loop);
        _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
        timerState.value = TimerState.completed;
      }
    });
  }

  void start(int seconds) {
    // Set timer
    _initialDuration = seconds;
    notifier.value = seconds;
    _timer?.cancel();

    // Change timer state
    timerState.value = TimerState.running;

    _startTicking(seconds);
  }

  void reset() {
    stop();
    start(_initialDuration);
  }

  void pause() {
    // Change timer state
    timerState.value = TimerState.paused;

    if (_timer == null) {
      return;
    }

    _timer!.cancel();
    _timer = null;
  }

  void stop() {
    timerState.value = TimerState.idle;
    _timer?.cancel();
    _audioPlayer.stop();
  }

  void resume() {
    timerState.value = TimerState.running;
    _startTicking(notifier.value);
  }

  void dispose() {
    _timer?.cancel();
    notifier.dispose();
    _audioPlayer.dispose();
  }
}
