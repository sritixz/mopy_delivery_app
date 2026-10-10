import 'dart:async';
import 'package:flutter/material.dart';
import '../models/runner_models.dart';
import '../services/duty_service.dart';

class DutyProvider extends ChangeNotifier {
  String _dutyStatus = 'Online';
  ShiftInfo? _currentShift;
  Timer? _shiftTimer;
  int _activeTasksCount = 1;
  final int _maxCapacity = 4;

  String get dutyStatus => _dutyStatus;
  ShiftInfo? get currentShift => _currentShift;
  int get activeTasksCount => _activeTasksCount;
  int get maxCapacity => _maxCapacity;
  bool get isOnline => _dutyStatus == 'Online';
  bool get isOnBreak => _dutyStatus == 'On Break';
  bool get isOffline => _dutyStatus == 'Offline';

  DutyProvider() {
    // Start initial shift for demonstration
    startShift();
  }

  void startShift() {
    _dutyStatus = 'Online';
    _currentShift = ShiftInfo(shiftStart: DateTime.now().subtract(const Duration(minutes: 42)));
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _shiftTimer?.cancel();
    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  Future<void> setDutyStatus(String newStatus) async {
    _dutyStatus = newStatus;
    if (newStatus == 'Offline') {
      _currentShift?.shiftEnd = DateTime.now();
      _shiftTimer?.cancel();
    } else if (_currentShift == null || _currentShift?.shiftEnd != null) {
      _currentShift = ShiftInfo(shiftStart: DateTime.now());
      _startTimer();
    }
    notifyListeners();

    try {
      await DutyService.setDutyStatus(newStatus);
    } catch (_) {}
  }

  void updateActiveTasksCount(int count) {
    _activeTasksCount = count;
    notifyListeners();
  }

  @override
  void dispose() {
    _shiftTimer?.cancel();
    super.dispose();
  }
}
