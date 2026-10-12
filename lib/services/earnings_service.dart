import 'dart:convert';
import '../models/earnings_models.dart';
import 'api_service.dart';

class EarningsService {
  // Fetch today's earnings & weekly total
  static Future<Map<String, dynamic>> getEarningsSummary() async {
    try {
      final response = await ApiService.get('/delivery/earnings/summary');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return {
            'today': TodayEarnings.fromJson(data['today']),
            'weeklyTotal': (data['weeklyTotal'] as num?)?.toDouble() ?? 3420.0,
            'weeklyDeliveries': (data['weeklyDeliveries'] as num?)?.toInt() ?? 72,
          };
        }
      }
    } catch (_) {}

    // Offline demo fallback
    return {
      'today': TodayEarnings(
        deliveriesCount: 6,
        baseShiftPay: 350.0,
        perOrderPay: 180.0,
        batchBonus: 60.0,
        tips: 0.0,
        netEarnings: 590.0,
        settlementStatus: 'Pending',
      ),
      'weeklyTotal': 3420.0,
      'weeklyDeliveries': 72,
    };
  }

  // Fetch earnings history
  static Future<List<EarningsHistoryItem>> getEarningsHistory() async {
    try {
      final response = await ApiService.get('/delivery/earnings/history');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['history'] is List) {
          final list = (data['history'] as List)
              .map((e) => EarningsHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {}

    // Mock history
    final now = DateTime.now();
    return [
      EarningsHistoryItem(
        id: 'hist-1',
        date: now.subtract(const Duration(days: 1)),
        deliveriesCount: 14,
        netEarnings: 820.0,
        settlementStatus: 'Settled',
      ),
      EarningsHistoryItem(
        id: 'hist-2',
        date: now.subtract(const Duration(days: 2)),
        deliveriesCount: 12,
        netEarnings: 740.0,
        settlementStatus: 'Settled',
      ),
      EarningsHistoryItem(
        id: 'hist-3',
        date: now.subtract(const Duration(days: 3)),
        deliveriesCount: 16,
        netEarnings: 910.0,
        settlementStatus: 'Settled',
      ),
      EarningsHistoryItem(
        id: 'hist-4',
        date: now.subtract(const Duration(days: 4)),
        deliveriesCount: 10,
        netEarnings: 650.0,
        settlementStatus: 'Settled',
      ),
    ];
  }

  // Clock-out & generate shift slip
  static Future<ShiftSummary?> clockOutShift() async {
    try {
      final response = await ApiService.post('/delivery/shift/clock-out', {});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ShiftSummary.fromJson(data);
        }
      }
    } catch (_) {}

    return ShiftSummary(
      totalOnlineMinutes: 380,
      totalDeliveries: 8,
      onTimeDeliveries: 8,
      slaRate: 100.0,
      netEarnings: 650.0,
    );
  }

  // Raise dispute
  static Future<String?> raiseDispute({
    required String reason,
    String? notes,
    String? earningsId,
  }) async {
    try {
      final response = await ApiService.post('/delivery/disputes', {
        'reason': reason,
        'notes': notes ?? '',
        'earningsId': earningsId,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['ticketId'] ?? 'DISP-88912').toString();
      }
    } catch (_) {}

    return 'DISP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }
}
