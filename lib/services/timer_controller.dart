import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_pomodoro/models/completed_session.dart';
import 'package:flutter_pomodoro/services/firestore_service.dart';

import '../features/categories/category_picker.dart';

enum TimerState { idle, running, paused, completed }

class TimerController {
  ValueNotifier<int> notifier = ValueNotifier(0);
  ValueNotifier<TimerState> timerState = ValueNotifier(TimerState.idle);
  ValueNotifier<List<CompletedSession>> completedSessions = ValueNotifier([]);
  Category? category;
  late DateTime startedAt;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late int _initialDuration;
  Duration get initialDuration => Duration(seconds: _initialDuration);
  Timer? _timer;

  void _startTicking(int seconds) {
    // Begin timer countdown
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      notifier.value = notifier.value - 1;
      if (notifier.value <= 0) {
        // When the timer ends,
        // Clear timer
        timer.cancel();
        // Play sound
        _audioPlayer.setReleaseMode(ReleaseMode.loop);
        _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
        // Update internal state
        timerState.value = TimerState.completed;
        // Trigger a save
        save();
      }
    });
  }

  void start(int seconds, Category? category) {
    // Set category
    this.category = category;
    // Set timer
    _initialDuration = seconds;
    notifier.value = seconds;
    _timer?.cancel();
    // Record start time
    startedAt = DateTime.now();

    // Change timer state
    timerState.value = TimerState.running;

    _startTicking(seconds);
  }

  void reset() {
    stop();
    start(_initialDuration, category);
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
    // The user will be navigated to the timer tab (countdown_screen will be popped)
    // Skip saving if the timer state is completed: data has already been saved
    if (timerState.value != TimerState.completed) {
      // Start saving process
      // Compute the elapsed time
      int elapsed = _initialDuration - notifier.value;
      // Save if the elapsed time is at least 60 seconds
      if (elapsed >= 60) {
        save();
      }
    }
    // Update timer state
    timerState.value = TimerState.idle;
    _timer?.cancel();
    _audioPlayer.stop();
  }

  void resume() {
    timerState.value = TimerState.running;
    _startTicking(notifier.value);
  }

  void save() {
    int elapsed = _initialDuration - notifier.value;

    CompletedSession newSession = CompletedSession(
      category: category,
      timerDuration: Duration(
        seconds: elapsed > 0 ? elapsed : _initialDuration,
      ),
      startedAt: startedAt,
    );

    // Save to internal list
    completedSessions.value = [...completedSessions.value, newSession];

    // Save to firestore
    // get user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().saveSession(user.uid, newSession);
    }
  }

  void dispose() {
    _timer?.cancel();
    notifier.dispose();
    _audioPlayer.dispose();
  }
}
