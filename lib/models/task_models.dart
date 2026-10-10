class DeliveryDeskInfo {
  final String tower;
  final String floor;
  final String deskNumber;
  final String department;
  final String employeeName;
  final String employeePhone;
  final String buildingAccessInstructions;

  DeliveryDeskInfo({
    this.tower = 'Tower A',
    this.floor = 'Floor 3',
    this.deskNumber = 'Desk 302',
    this.department = 'Engineering',
    this.employeeName = '',
    this.employeePhone = '',
    this.buildingAccessInstructions = '',
  });

  factory DeliveryDeskInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DeliveryDeskInfo();
    return DeliveryDeskInfo(
      tower: (json['tower'] ?? 'Tower A').toString(),
      floor: (json['floor'] ?? 'Floor 3').toString(),
      deskNumber: (json['deskNumber'] ?? '').toString(),
      department: (json['department'] ?? '').toString(),
      employeeName: (json['employeeName'] ?? '').toString(),
      employeePhone: (json['employeePhone'] ?? '').toString(),
      buildingAccessInstructions: (json['buildingAccessInstructions'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tower': tower,
      'floor': floor,
      'deskNumber': deskNumber,
      'department': department,
      'employeeName': employeeName,
      'employeePhone': employeePhone,
      'buildingAccessInstructions': buildingAccessInstructions,
    };
  }

  String get shortLocation => '$tower • $floor ${deskNumber.isNotEmpty ? '• $deskNumber' : ''}';
}

class TaskItem {
  final String name;
  final int quantity;
  final double price;
  final String notes;

  TaskItem({
    required this.name,
    required this.quantity,
    this.price = 0.0,
    this.notes = '',
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    String itemName = 'Meal Box';
    if (json['item'] is Map) {
      itemName = (json['item']['name'] ?? json['name'] ?? 'Meal Box').toString();
    } else {
      itemName = (json['name'] ?? 'Meal Box').toString();
    }
    return TaskItem(
      name: itemName,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      notes: (json['notes'] ?? '').toString(),
    );
  }
}

class PickupItemChecklist {
  final String itemId;
  final String name;
  final int quantity;
  bool isPacked;
  final String notes;

  PickupItemChecklist({
    required this.itemId,
    required this.name,
    required this.quantity,
    this.isPacked = false,
    this.notes = '',
  });

  factory PickupItemChecklist.fromJson(Map<String, dynamic> json) {
    return PickupItemChecklist(
      itemId: (json['itemId'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Item').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      isPacked: json['isPacked'] == true,
      notes: (json['notes'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'isPacked': isPacked,
      'notes': notes,
    };
  }
}

class DeliveryTask {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final List<TaskItem> items;
  final double totalAmount;
  final String paymentStatus;
  final String orderStatus;
  String deliveryStatus; // 'unassigned', 'assigned', 'accepted', 'picked_up', 'in_transit', 'delivered', 'failed', 'reassigned'
  final DeliveryDeskInfo deliveryDeskInfo;
  final String outletName;
  final String outletAddress;
  final DateTime? slaDeadline;
  final DateTime? assignedAt;
  final List<PickupItemChecklist> pickupChecklist;
  final bool isPriority;
  final DateTime? reassignmentDeadline;
  final String? batchRunId;
  final Map<String, dynamic>? proofOfDelivery;
  final Map<String, dynamic>? deliveryException;
  final DateTime createdAt;

  DeliveryTask({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.items,
    required this.totalAmount,
    this.paymentStatus = 'Completed',
    this.orderStatus = 'Preparing',
    this.deliveryStatus = 'unassigned',
    required this.deliveryDeskInfo,
    this.outletName = 'MOPY Central Kitchen',
    this.outletAddress = 'Ground Floor, Food Court',
    this.slaDeadline,
    this.assignedAt,
    this.pickupChecklist = const [],
    this.isPriority = false,
    this.reassignmentDeadline,
    this.batchRunId,
    this.proofOfDelivery,
    this.deliveryException,
    required this.createdAt,
  });

  factory DeliveryTask.fromJson(Map<String, dynamic> json) {
    // Customer details
    String custName = 'Customer';
    String custPhone = '';
    if (json['customer'] is Map) {
      custName = (json['customer']['name'] ?? 'Customer').toString();
      custPhone = (json['customer']['phone'] ?? '').toString();
    } else if (json['customerName'] != null) {
      custName = json['customerName'].toString();
      custPhone = (json['customerPhone'] ?? '').toString();
    }

    // Items
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems.map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList();

    // Outlet
    String outName = 'MOPY Central Kitchen';
    String outAddr = 'Food Court Counter #2';
    if (json['outlet'] is Map) {
      outName = (json['outlet']['name'] ?? outName).toString();
      outAddr = (json['outlet']['address'] ?? outAddr).toString();
    }

    // Checklist
    final rawChecklist = json['pickupChecklist'] as List<dynamic>? ?? [];
    List<PickupItemChecklist> checklist = rawChecklist
        .map((e) => PickupItemChecklist.fromJson(e as Map<String, dynamic>))
        .toList();

    if (checklist.isEmpty && itemsList.isNotEmpty) {
      checklist = itemsList
          .map((i) => PickupItemChecklist(
                itemId: i.name,
                name: i.name,
                quantity: i.quantity,
                isPacked: false,
              ))
          .toList();
    }

    // Dates
    DateTime? sla;
    if (json['slaDeadline'] != null) {
      sla = DateTime.tryParse(json['slaDeadline'].toString());
    }
    DateTime? assigned;
    if (json['assignedAt'] != null) {
      assigned = DateTime.tryParse(json['assignedAt'].toString());
    }
    DateTime? reassign;
    if (json['reassignmentDeadline'] != null) {
      reassign = DateTime.tryParse(json['reassignmentDeadline'].toString());
    }
    DateTime created = DateTime.now();
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    }

    // Desk info
    DeliveryDeskInfo deskInfo;
    if (json['deliveryDeskInfo'] is Map) {
      deskInfo = DeliveryDeskInfo.fromJson(json['deliveryDeskInfo'] as Map<String, dynamic>);
    } else if (json['deliveryAddress'] is Map) {
      final addr = json['deliveryAddress'] as Map<String, dynamic>;
      deskInfo = DeliveryDeskInfo(
        tower: (addr['tower'] ?? addr['block'] ?? 'Tower A').toString(),
        floor: (addr['floor'] ?? 'Floor 3').toString(),
        deskNumber: (addr['deskNumber'] ?? addr['flat'] ?? '').toString(),
        department: (addr['department'] ?? '').toString(),
        employeeName: custName,
        employeePhone: custPhone,
        buildingAccessInstructions: (addr['instructions'] ?? '').toString(),
      );
    } else {
      deskInfo = DeliveryDeskInfo(
        employeeName: custName,
        employeePhone: custPhone,
      );
    }

    return DeliveryTask(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? json['id'] ?? 'ORD-000').toString(),
      customerName: custName,
      customerPhone: custPhone,
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: (json['paymentStatus'] ?? 'Completed').toString(),
      orderStatus: (json['orderStatus'] ?? 'Preparing').toString(),
      deliveryStatus: (json['deliveryStatus'] ?? 'unassigned').toString(),
      deliveryDeskInfo: deskInfo,
      outletName: outName,
      outletAddress: outAddr,
      slaDeadline: sla,
      assignedAt: assigned,
      pickupChecklist: checklist,
      isPriority: json['isPriority'] == true,
      reassignmentDeadline: reassign,
      batchRunId: json['batchRunId']?.toString(),
      proofOfDelivery: json['proofOfDelivery'] as Map<String, dynamic>?,
      deliveryException: json['deliveryException'] as Map<String, dynamic>?,
      createdAt: created,
    );
  }

  int get totalItemCount => items.fold(0, (acc, item) => acc + item.quantity);

  int get remainingSecondsToReassign {
    if (reassignmentDeadline == null) return 60;
    final diff = reassignmentDeadline!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  int get remainingSlaMinutes {
    if (slaDeadline == null) return 15;
    return slaDeadline!.difference(DateTime.now()).inMinutes;
  }
}

class BatchRun {
  final String id;
  final String batchNumber;
  final String runnerId;
  final List<DeliveryTask> orders;
  final String status; // 'assigned', 'picked_up', 'in_transit', 'completed', 'cancelled'
  final String campus;
  final String tower;
  final String floor;
  final int totalOrders;
  final int completedOrders;
  final DateTime? startedAt;
  final DateTime? completedAt;

  BatchRun({
    required this.id,
    required this.batchNumber,
    required this.runnerId,
    required this.orders,
    this.status = 'assigned',
    this.campus = 'Embassy TechVillage',
    this.tower = 'Tower B',
    this.floor = 'Floor 4',
    this.totalOrders = 1,
    this.completedOrders = 0,
    this.startedAt,
    this.completedAt,
  });

  factory BatchRun.fromJson(Map<String, dynamic> json) {
    final rawOrders = json['orders'] as List<dynamic>? ?? [];
    final ordersList = rawOrders.map((e) {
      if (e is Map<String, dynamic>) {
        return DeliveryTask.fromJson(e);
      }
      return DeliveryTask(
        id: e.toString(),
        orderNumber: e.toString(),
        customerName: 'Customer',
        customerPhone: '',
        items: [],
        totalAmount: 0,
        deliveryDeskInfo: DeliveryDeskInfo(),
        createdAt: DateTime.now(),
      );
    }).toList();

    return BatchRun(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      batchNumber: (json['batchNumber'] ?? 'BATCH-001').toString(),
      runnerId: (json['runner'] ?? '').toString(),
      orders: ordersList,
      status: (json['status'] ?? 'assigned').toString(),
      campus: (json['campus'] ?? 'Embassy TechVillage').toString(),
      tower: (json['tower'] ?? 'Tower B').toString(),
      floor: (json['floor'] ?? 'Floor 4').toString(),
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? ordersList.length,
      completedOrders: (json['completedOrders'] as num?)?.toInt() ?? 0,
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt'].toString()) : null,
    );
  }
}
