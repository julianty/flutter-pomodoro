import 'dart:async';

import 'package:flutter/material.dart';

class TimerController {
  ValueNotifier<int> notifier = ValueNotifier(0);

  Timer? _timer;

  void start(int seconds) {
    notifier.value = seconds;
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      notifier.value = notifier.value - 1;
      if (notifier.value <= 0) {
        timer.cancel();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    notifier.value = 0;
  }

  void dispose() {
    _timer?.cancel();
    notifier.dispose();
  }
}
