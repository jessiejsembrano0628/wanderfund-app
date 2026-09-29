import 'dart:async';

import 'package:flutter/widgets.dart';

class IdleSessionManager with WidgetsBindingObserver {
  final Duration timeout;
  final VoidCallback onTimeout;

  Timer? _timer;
  DateTime? _lastActivity;
  bool _enabled = false;
  bool _timedOut = false;

  IdleSessionManager({required this.timeout, required this.onTimeout});

  void start() {
    if (_enabled) return;
    _enabled = true;
    _timedOut = false;
    _lastActivity = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
    _scheduleTimer();
  }

  void stop() {
    _enabled = false;
    _timer?.cancel();
    _timer = null;
    _lastActivity = null;
    WidgetsBinding.instance.removeObserver(this);
  }

  void recordActivity() {
    if (!_enabled || _timedOut) return;
    _lastActivity = DateTime.now();
    _scheduleTimer();
  }

  void dispose() {
    stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_enabled || state != AppLifecycleState.resumed) return;
    _checkTimeout();
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, _checkTimeout);
  }

  void _checkTimeout() {
    if (!_enabled || _timedOut || _lastActivity == null) return;
    final elapsed = DateTime.now().difference(_lastActivity!);
    if (elapsed < timeout) {
      _timer = Timer(timeout - elapsed, _checkTimeout);
      return;
    }

    _timedOut = true;
    _timer?.cancel();
    _timer = null;
    onTimeout();
  }
}
