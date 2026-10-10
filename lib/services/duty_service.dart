import 'api_service.dart';

class DutyService {
  static Future<Map<String, dynamic>?> setDutyStatus(String status) async {
    final response = await ApiService.patch('/users/profile/me', {
      'dutyStatus': status,
    });
    if (response != null && response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getWorkloadStatus() async {
    final response = await ApiService.get('/orders/delivery-staff/workload');
    if (response != null && response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return null;
  }
}
