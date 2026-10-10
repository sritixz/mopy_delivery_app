import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env_config.dart';

class ApiService {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('runner_auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('runner_auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('runner_auth_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('${EnvConfig.baseUrl}$endpoint'),
            headers: await _headers(),
          )
          .timeout(const Duration(seconds: EnvConfig.connectTimeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) return decoded;
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('ApiService GET $endpoint error: $e');
      return null;
    }
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(
            Uri.parse('${EnvConfig.baseUrl}$endpoint'),
            headers: await _headers(),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: EnvConfig.connectTimeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) return decoded;
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('ApiService POST $endpoint error: $e');
      return null;
    }
  }

  static Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .patch(
            Uri.parse('${EnvConfig.baseUrl}$endpoint'),
            headers: await _headers(),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: EnvConfig.connectTimeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) return decoded;
      } catch (_) {}
      return null;
    } catch (e) {
      debugPrint('ApiService PATCH $endpoint error: $e');
      return null;
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('${EnvConfig.baseUrl}$endpoint'),
            headers: await _headers(),
            body: json.encode(data),
          )
          .timeout(const Duration(seconds: EnvConfig.connectTimeoutSeconds));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('ApiService PUT $endpoint error: $e');
      return null;
    }
  }
}
