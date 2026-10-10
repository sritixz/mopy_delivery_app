class RunnerUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  String dutyStatus; // 'Online', 'Offline', 'On Break'
  final String approvalStatus; // 'Approved', 'Pending', 'Suspended'
  final String vehicleType;
  final int maxCapacity;
  final String outletId;
  final String outletName;
  final DeliveryZone? assignedZone;
  final String? photoUrl;
  final String? idProofType;
  final String? idProofUrl;
  final bool isVerified;

  RunnerUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'Delivery Staff',
    this.dutyStatus = 'Offline',
    this.approvalStatus = 'Approved',
    this.vehicleType = 'On Foot',
    this.maxCapacity = 4,
    this.outletId = '',
    this.outletName = 'MOPY Kiosk #1',
    this.assignedZone,
    this.photoUrl,
    this.idProofType,
    this.idProofUrl,
    this.isVerified = true,
  });

  factory RunnerUser.fromJson(Map<String, dynamic> json) {
    String outId = '';
    String outName = 'MOPY Kiosk #1';
    if (json['outlet'] is Map) {
      outId = (json['outlet']['_id'] ?? json['outlet']['outletId'] ?? '').toString();
      outName = (json['outlet']['name'] ?? 'MOPY Kiosk #1').toString();
    } else if (json['outlet'] != null) {
      outId = json['outlet'].toString();
    }

    DeliveryZone? zone;
    if (json['assignedZone'] is Map) {
      zone = DeliveryZone.fromJson(json['assignedZone']);
    }

    final kyc = json['kycDocuments'] as Map<String, dynamic>?;

    return RunnerUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Runner Staff').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      role: (json['role'] ?? 'Delivery Staff').toString(),
      dutyStatus: (json['dutyStatus'] ?? 'Offline').toString(),
      approvalStatus: (json['approvalStatus'] ?? 'Approved').toString(),
      vehicleType: (json['vehicleType'] ?? 'On Foot').toString(),
      maxCapacity: json['maxCapacity'] ?? 4,
      outletId: outId,
      outletName: outName,
      assignedZone: zone,
      photoUrl: kyc?['photoUrl']?.toString(),
      idProofType: kyc?['idProofType']?.toString() ?? 'Aadhaar',
      idProofUrl: kyc?['idProofUrl']?.toString(),
      isVerified: kyc?['verified'] == true || (json['approvalStatus'] == 'Approved'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'dutyStatus': dutyStatus,
      'approvalStatus': approvalStatus,
      'vehicleType': vehicleType,
      'maxCapacity': maxCapacity,
      'outlet': outletId,
      'outletName': outletName,
      'isVerified': isVerified,
    };
  }
}

class DeliveryZone {
  final String officeComplex;
  final List<String> buildings;
  final List<String> floors;

  DeliveryZone({
    required this.officeComplex,
    required this.buildings,
    required this.floors,
  });

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    return DeliveryZone(
      officeComplex: (json['officeComplex'] ?? 'Main Tech Park Campus').toString(),
      buildings: (json['buildings'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Tower A', 'Tower B'],
      floors: (json['floors'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Floor 1', 'Floor 4', 'Floor 7', 'Floor 12'],
    );
  }
}

class ShiftInfo {
  final DateTime shiftStart;
  DateTime? shiftEnd;
  int activeMinutes;
  int breakMinutes;
  int completedTasks;
  int failedTasks;
  double earnings;

  ShiftInfo({
    required this.shiftStart,
    this.shiftEnd,
    this.activeMinutes = 0,
    this.breakMinutes = 0,
    this.completedTasks = 0,
    this.failedTasks = 0,
    this.earnings = 0.0,
  });

  String get durationString {
    final diff = (shiftEnd ?? DateTime.now()).difference(shiftStart);
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
