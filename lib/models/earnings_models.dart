class TodayEarnings {
  final int deliveriesCount;
  final double baseShiftPay;
  final double perOrderPay;
  final double batchBonus;
  final double tips;
  final double netEarnings;
  final String settlementStatus;

  TodayEarnings({
    this.deliveriesCount = 6,
    this.baseShiftPay = 350.0,
    this.perOrderPay = 180.0,
    this.batchBonus = 60.0,
    this.tips = 0.0,
    this.netEarnings = 590.0,
    this.settlementStatus = 'Pending',
  });

  factory TodayEarnings.fromJson(Map<String, dynamic> json) {
    return TodayEarnings(
      deliveriesCount: (json['deliveriesCount'] as num?)?.toInt() ?? 0,
      baseShiftPay: (json['baseShiftPay'] as num?)?.toDouble() ?? 350.0,
      perOrderPay: (json['perOrderPay'] as num?)?.toDouble() ?? 0.0,
      batchBonus: (json['batchBonus'] as num?)?.toDouble() ?? 0.0,
      tips: (json['tips'] as num?)?.toDouble() ?? 0.0,
      netEarnings: (json['netEarnings'] as num?)?.toDouble() ?? 350.0,
      settlementStatus: (json['settlementStatus'] ?? 'Pending').toString(),
    );
  }
}

class EarningsHistoryItem {
  final String id;
  final DateTime date;
  final int deliveriesCount;
  final double netEarnings;
  final String settlementStatus;
  final String disputeReason;

  EarningsHistoryItem({
    required this.id,
    required this.date,
    required this.deliveriesCount,
    required this.netEarnings,
    this.settlementStatus = 'Settled',
    this.disputeReason = '',
  });

  factory EarningsHistoryItem.fromJson(Map<String, dynamic> json) {
    return EarningsHistoryItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now() : DateTime.now(),
      deliveriesCount: (json['deliveriesCount'] as num?)?.toInt() ?? 0,
      netEarnings: (json['netEarnings'] as num?)?.toDouble() ?? 0.0,
      settlementStatus: (json['settlementStatus'] ?? 'Settled').toString(),
      disputeReason: (json['disputeReason'] ?? '').toString(),
    );
  }
}

class ShiftSummary {
  final int totalOnlineMinutes;
  final int totalDeliveries;
  final int onTimeDeliveries;
  final double slaRate;
  final double netEarnings;

  ShiftSummary({
    required this.totalOnlineMinutes,
    required this.totalDeliveries,
    required this.onTimeDeliveries,
    required this.slaRate,
    required this.netEarnings,
  });

  factory ShiftSummary.fromJson(Map<String, dynamic> json) {
    final shift = json['shift'] as Map<String, dynamic>? ?? {};
    final earnings = json['earnings'] as Map<String, dynamic>? ?? {};

    return ShiftSummary(
      totalOnlineMinutes: (shift['totalOnlineMinutes'] as num?)?.toInt() ?? 360,
      totalDeliveries: (shift['totalDeliveries'] as num?)?.toInt() ?? 8,
      onTimeDeliveries: (shift['onTimeDeliveries'] as num?)?.toInt() ?? 8,
      slaRate: (shift['slaRate'] as num?)?.toDouble() ?? 100.0,
      netEarnings: (earnings['netEarnings'] as num?)?.toDouble() ?? 620.0,
    );
  }
}
