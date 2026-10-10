import 'api_service.dart';
import '../models/runner_models.dart';

class AuthService {
  static Future<Map<String, dynamic>?> login(String emailOrPhone, String password) async {
    final response = await ApiService.post('/auth/login', {
      'email': emailOrPhone.trim().toLowerCase(),
      'password': password,
    });

    if (response != null && (response['success'] == true || response['token'] != null)) {
      if (response['token'] != null) {
        await ApiService.saveToken(response['token']);
      }
      return response;
    }
    return response;
  }

  static Future<RunnerUser?> fetchProfile() async {
    final response = await ApiService.get('/auth/profile');
    if (response != null && response['user'] != null) {
      return RunnerUser.fromJson(response['user']);
    }
    final meResp = await ApiService.get('/auth/me');
    if (meResp != null && meResp is Map) {
      return RunnerUser.fromJson(Map<String, dynamic>.from(meResp));
    }
    return null;
  }

  static Future<bool> updateKyc({
    required String idProofType,
    required String idProofUrl,
    String? photoUrl,
    String? vehicleType,
  }) async {
    final payload = <String, dynamic>{
      'kycDocuments': {
        'idProofType': idProofType,
        'idProofUrl': idProofUrl,
        if (photoUrl != null) 'photoUrl': photoUrl,
      },
    };
    if (vehicleType != null) payload['vehicleType'] = vehicleType;
    final response = await ApiService.put('/users/profile/me', payload);
    return response != null;
  }
}
