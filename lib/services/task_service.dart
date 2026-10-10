import 'dart:convert';
import '../models/task_models.dart';
import 'api_service.dart';

class TaskService {

  // Mock data for offline or demo testing
  static final List<DeliveryTask> _mockAvailableTasks = [
    DeliveryTask(
      id: 'mock-order-101',
      orderNumber: 'MPY-8492',
      customerName: 'Rahul Verma',
      customerPhone: '+91 98765 43210',
      items: [
        TaskItem(name: 'Paneer Butter Masala Meal Box', quantity: 1, price: 249.0),
        TaskItem(name: 'Garlic Naan (2 pcs)', quantity: 1, price: 60.0),
        TaskItem(name: 'Sweet Lassi (300ml)', quantity: 1, price: 80.0),
      ],
      totalAmount: 389.0,
      paymentStatus: 'Paid (UPI)',
      orderStatus: 'Ready for Pickup',
      deliveryStatus: 'unassigned',
      outletName: 'MOPY Central Kitchen - Hub 1',
      outletAddress: 'Pantry Zone A, Ground Floor',
      deliveryDeskInfo: DeliveryDeskInfo(
        tower: 'Tower B',
        floor: 'Floor 4',
        deskNumber: 'Desk B-412',
        department: 'FinTech Engineering',
        employeeName: 'Rahul Verma',
        employeePhone: '+91 98765 43210',
        buildingAccessInstructions: 'Badge in at North Turnstile. Bay 4 nearest to Lift #3.',
      ),
      slaDeadline: DateTime.now().add(const Duration(minutes: 18)),
      pickupChecklist: [
        PickupItemChecklist(itemId: '1', name: 'Paneer Butter Masala Box', quantity: 1, isPacked: true),
        PickupItemChecklist(itemId: '2', name: 'Garlic Naan Foil Pack', quantity: 1, isPacked: true),
        PickupItemChecklist(itemId: '3', name: 'Sweet Lassi Bottle', quantity: 1, isPacked: true),
        PickupItemChecklist(itemId: '4', name: 'Cutlery & Napkin Kit', quantity: 1, isPacked: true),
      ],
      isPriority: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    DeliveryTask(
      id: 'mock-order-102',
      orderNumber: 'MPY-8495',
      customerName: 'Ananya Deshmukh',
      customerPhone: '+91 98111 22334',
      items: [
        TaskItem(name: 'Healthy Quinoa Buddha Bowl', quantity: 1, price: 299.0),
        TaskItem(name: 'Fresh Cold Pressed Orange Juice', quantity: 1, price: 120.0),
      ],
      totalAmount: 419.0,
      paymentStatus: 'Paid (Corporate Wallet)',
      orderStatus: 'Ready for Pickup',
      deliveryStatus: 'unassigned',
      outletName: 'MOPY Central Kitchen - Hub 1',
      outletAddress: 'Pantry Zone A, Ground Floor',
      deliveryDeskInfo: DeliveryDeskInfo(
        tower: 'Tower B',
        floor: 'Floor 4',
        deskNumber: 'Desk B-418',
        department: 'Product Operations',
        employeeName: 'Ananya Deshmukh',
        employeePhone: '+91 98111 22334',
        buildingAccessInstructions: 'Desk located adjacent to Agile Room 4B.',
      ),
      slaDeadline: DateTime.now().add(const Duration(minutes: 24)),
      pickupChecklist: [
        PickupItemChecklist(itemId: '1', name: 'Quinoa Buddha Bowl', quantity: 1, isPacked: true),
        PickupItemChecklist(itemId: '2', name: 'Cold Pressed Orange Juice', quantity: 1, isPacked: true),
        PickupItemChecklist(itemId: '3', name: 'Wooden Spoon & Fork', quantity: 1, isPacked: true),
      ],
      isPriority: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
    ),
    DeliveryTask(
      id: 'mock-order-103',
      orderNumber: 'MPY-8501',
      customerName: 'Karthik Subbaraj',
      customerPhone: '+91 97400 88991',
      items: [
        TaskItem(name: 'Chicken Biryani Feast Box', quantity: 2, price: 580.0),
        TaskItem(name: 'Raita & Salan Cups', quantity: 2, price: 40.0),
        TaskItem(name: 'Gulab Jamun (2 pcs)', quantity: 1, price: 70.0),
      ],
      totalAmount: 690.0,
      paymentStatus: 'Paid (UPI)',
      orderStatus: 'Ready for Pickup',
      deliveryStatus: 'unassigned',
      outletName: 'MOPY Central Kitchen - Hub 1',
      outletAddress: 'Pantry Zone A, Ground Floor',
      deliveryDeskInfo: DeliveryDeskInfo(
        tower: 'Tower A',
        floor: 'Floor 2',
        deskNumber: 'Desk A-205',
        department: 'Cloud Infrastructure',
        employeeName: 'Karthik Subbaraj',
        employeePhone: '+91 97400 88991',
        buildingAccessInstructions: 'Enter Tower A lobby, take elevator to 2nd floor east wing.',
      ),
      slaDeadline: DateTime.now().add(const Duration(minutes: 32)),
      pickupChecklist: [
        PickupItemChecklist(itemId: '1', name: 'Chicken Biryani Boxes (2)', quantity: 2, isPacked: true),
        PickupItemChecklist(itemId: '2', name: 'Raita & Salan Cups', quantity: 2, isPacked: true),
        PickupItemChecklist(itemId: '3', name: 'Gulab Jamun Pack', quantity: 1, isPacked: true),
      ],
      isPriority: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
  ];

  static final List<DeliveryTask> _mockActiveTasks = [
    DeliveryTask(
      id: 'mock-assigned-201',
      orderNumber: 'MPY-8488',
      customerName: 'Pooja Hegde',
      customerPhone: '+91 99887 76655',
      items: [
        TaskItem(name: 'South Indian Filter Coffee', quantity: 2, price: 100.0),
        TaskItem(name: 'Crispy Medu Vada (2 pcs)', quantity: 1, price: 80.0),
      ],
      totalAmount: 180.0,
      paymentStatus: 'Paid (UPI)',
      orderStatus: 'Ready for Pickup',
      deliveryStatus: 'assigned',
      outletName: 'MOPY Central Kitchen - Hub 1',
      outletAddress: 'Pantry Zone A, Ground Floor',
      deliveryDeskInfo: DeliveryDeskInfo(
        tower: 'Tower B',
        floor: 'Floor 4',
        deskNumber: 'Desk B-402',
        department: 'Human Resources',
        employeeName: 'Pooja Hegde',
        employeePhone: '+91 99887 76655',
        buildingAccessInstructions: 'Reception area opposite Meeting Room Magnolia.',
      ),
      slaDeadline: DateTime.now().add(const Duration(minutes: 15)),
      reassignmentDeadline: DateTime.now().add(const Duration(seconds: 48)),
      pickupChecklist: [
        PickupItemChecklist(itemId: '1', name: 'Hot Flask Filter Coffee (2)', quantity: 2, isPacked: false),
        PickupItemChecklist(itemId: '2', name: 'Medu Vada Box & Chutney', quantity: 1, isPacked: false),
      ],
      isPriority: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
  ];

  // Fetch available tasks ready for assignment
  Future<List<DeliveryTask>> getAvailableTasks({String? campus, String? tower}) async {
    try {
      String path = '/delivery/tasks/available';
      final params = <String>[];
      if (campus != null && campus.isNotEmpty) params.add('campus=${Uri.encodeComponent(campus)}');
      if (tower != null && tower.isNotEmpty) params.add('tower=${Uri.encodeComponent(tower)}');
      if (params.isNotEmpty) path += '?${params.join('&')}';

      final response = await ApiService.get(path);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['tasks'] is List) {
          final list = (data['tasks'] as List)
              .map((e) => DeliveryTask.fromJson(e as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) return list;
        }
      }
    } catch (_) {
      // Offline fallback
    }
    return List<DeliveryTask>.from(_mockAvailableTasks);
  }

  // Fetch active runner tasks (assigned, accepted, in transit)
  Future<List<DeliveryTask>> getActiveTasks() async {
    try {
      final response = await ApiService.get('/delivery/tasks/active');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['tasks'] is List) {
          final list = (data['tasks'] as List)
              .map((e) => DeliveryTask.fromJson(e as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (_) {
      // Offline fallback
    }
    return List<DeliveryTask>.from(_mockActiveTasks);
  }

  // Accept a task
  Future<DeliveryTask?> acceptTask(String taskId) async {
    try {
      final response = await ApiService.post('/delivery/tasks/$taskId/accept', {});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['task'] != null) {
          return DeliveryTask.fromJson(data['task']);
        }
      }
    } catch (_) {
      // Demo fallback: update mock
      for (final t in _mockActiveTasks) {
        if (t.id == taskId) {
          t.deliveryStatus = 'accepted';
          return t;
        }
      }
      for (final t in _mockAvailableTasks) {
        if (t.id == taskId) {
          t.deliveryStatus = 'accepted';
          _mockAvailableTasks.remove(t);
          _mockActiveTasks.add(t);
          return t;
        }
      }
    }
    return null;
  }

  // Reject a task with structured reason
  Future<bool> rejectTask(String taskId, {required String reason, String? notes}) async {
    try {
      final response = await ApiService.post('/delivery/tasks/$taskId/reject', {
        'reason': reason,
        'notes': notes ?? '',
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {
      // Demo fallback
      _mockActiveTasks.removeWhere((t) => t.id == taskId);
      _mockAvailableTasks.removeWhere((t) => t.id == taskId);
      return true;
    }
    return false;
  }

  // Confirm pantry counter pickup with item checklist
  Future<DeliveryTask?> pickupTask(String taskId, {List<PickupItemChecklist>? checklist}) async {
    try {
      final body = <String, dynamic>{};
      if (checklist != null) {
        body['checklist'] = checklist.map((e) => e.toJson()).toList();
      }
      final response = await ApiService.post('/delivery/tasks/$taskId/pickup', body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['task'] != null) {
          return DeliveryTask.fromJson(data['task']);
        }
      }
    } catch (_) {
      // Demo fallback
      for (final t in _mockActiveTasks) {
        if (t.id == taskId) {
          t.deliveryStatus = 'picked_up';
          return t;
        }
      }
    }
    return null;
  }

  // Multi-order batch grouping
  Future<BatchRun?> createBatch(List<String> orderIds, {String? tower, String? floor}) async {
    try {
      final response = await ApiService.post('/delivery/tasks/batch', {
        'orderIds': orderIds,
        'tower': tower ?? 'Tower B',
        'floor': floor ?? 'Floor 4',
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['batch'] != null) {
          return BatchRun.fromJson(data['batch']);
        }
      }
    } catch (_) {
      // Demo fallback
      final matchedOrders = _mockActiveTasks.where((t) => orderIds.contains(t.id)).toList();
      return BatchRun(
        id: 'batch-${DateTime.now().millisecondsSinceEpoch}',
        batchNumber: 'BATCH-${(100 + orderIds.length)}',
        runnerId: 'runner-001',
        orders: matchedOrders,
        status: 'assigned',
        tower: tower ?? 'Tower B',
        floor: floor ?? 'Floor 4',
        totalOrders: orderIds.length,
        startedAt: DateTime.now(),
      );
    }
    return null;
  }

  // Update status (e.g. in_transit, delivered)
  Future<bool> updateStatus(String taskId, String status) async {
    try {
      final response = await ApiService.put('/delivery/tasks/$taskId/status', {
        'status': status,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
    } catch (_) {
      for (final t in _mockActiveTasks) {
        if (t.id == taskId) {
          t.deliveryStatus = status;
          return true;
        }
      }
    }
    return false;
  }
}
