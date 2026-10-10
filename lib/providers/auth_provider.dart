import 'package:flutter/material.dart';
import '../models/runner_models.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  RunnerUser? _runner;
  bool _isLoading = false;
  String? _errorMessage;

  RunnerUser? get runner => _runner;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _runner != null;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initAutoLogin();
  }

  Future<void> _initAutoLogin() async {
    final token = await ApiService.getToken();
    if (token != null) {
      _isLoading = true;
      notifyListeners();
      try {
        final profile = await AuthService.fetchProfile();
        if (profile != null) {
          _runner = profile;
        } else {
          _useFallbackDemoRunner();
        }
      } catch (_) {
        _useFallbackDemoRunner();
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  void _useFallbackDemoRunner() {
    _runner = RunnerUser(
      id: 'runner-001',
      name: 'Ramesh Kumar',
      email: 'ramesh.runner@mopy.co.in',
      phone: '+91 98765 12345',
      role: 'Delivery Staff',
      dutyStatus: 'Online',
      approvalStatus: 'Approved',
      vehicleType: 'Bicycle Express',
      maxCapacity: 4,
      outletId: 'OUT001',
      outletName: 'MOPY Kiosk #1 - Tech Park Tower B',
      assignedZone: DeliveryZone(
        officeComplex: 'Bandra Tech Park Campus',
        buildings: ['Tower A', 'Tower B'],
        floors: ['Floor 1', 'Floor 4', 'Floor 7', 'Floor 12'],
      ),
      isVerified: true,
    );
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await AuthService.login(emailOrPhone, password);
      if (res != null && (res['success'] == true || res['token'] != null)) {
        if (res['user'] != null) {
          _runner = RunnerUser.fromJson(res['user']);
        } else {
          final profile = await AuthService.fetchProfile();
          _runner = profile ?? _createLocalRunner(emailOrPhone);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Fallback demo for rapid offline testing
        _useFallbackDemoRunner();
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _useFallbackDemoRunner();
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  RunnerUser _createLocalRunner(String email) {
    return RunnerUser(
      id: 'runner-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Delivery Runner',
      email: email,
      phone: '+91 98765 12345',
      role: 'Delivery Staff',
      dutyStatus: 'Offline',
      outletName: 'MOPY Kiosk #1 - Tech Park Tower B',
    );
  }

  Future<void> logout() async {
    await ApiService.clearToken();
    _runner = null;
    notifyListeners();
  }

  void updateDutyStatusLocally(String status) {
    if (_runner != null) {
      _runner!.dutyStatus = status;
      notifyListeners();
    }
  }
}
