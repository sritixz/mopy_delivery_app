import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/task_models.dart';
import '../services/task_service.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<DeliveryTask> _availableTasks = [];
  List<DeliveryTask> _activeTasks = [];
  final List<BatchRun> _batches = [];
  final Set<String> _selectedBatchTaskIds = {};

  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollTimer;
  Timer? _reassignTicker;

  // Track known task IDs to detect incoming new orders
  final Set<String> _knownAssignedIds = {};

  List<DeliveryTask> get availableTasks => _availableTasks;
  List<DeliveryTask> get activeTasks => _activeTasks;
  List<BatchRun> get batches => _batches;
  Set<String> get selectedBatchTaskIds => _selectedBatchTaskIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<DeliveryTask> get assignedTasks =>
      _activeTasks.where((t) => t.deliveryStatus == 'assigned').toList();

  List<DeliveryTask> get acceptedTasks =>
      _activeTasks.where((t) => t.deliveryStatus == 'accepted').toList();

  List<DeliveryTask> get pickedUpTasks =>
      _activeTasks.where((t) => t.deliveryStatus == 'picked_up' || t.deliveryStatus == 'in_transit').toList();

  List<DeliveryTask> get deliveredTasks =>
      _activeTasks.where((t) => t.deliveryStatus == 'delivered').toList();

  TaskProvider() {
    _startReassignTicker();
    fetchTasks();
  }

  // Periodic ticker to decrement reassign deadlines smoothly in UI
  void _startReassignTicker() {
    _reassignTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (assignedTasks.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  // Periodic polling for tasks when runner is Online
  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchTasks(silent: true);
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // Fetch both available and assigned tasks
  Future<void> fetchTasks({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final available = await _taskService.getAvailableTasks();
      final active = await _taskService.getActiveTasks();

      // Check if new task arrived to vibrate/alert runner
      final currentAssignedIds = active.where((t) => t.deliveryStatus == 'assigned').map((t) => t.id).toSet();
      final hasNewAssigned = currentAssignedIds.difference(_knownAssignedIds).isNotEmpty;
      if (hasNewAssigned && _knownAssignedIds.isNotEmpty) {
        HapticFeedback.heavyImpact();
      }
      _knownAssignedIds.clear();
      _knownAssignedIds.addAll(currentAssignedIds);

      _availableTasks = available;
      _activeTasks = active;
      _errorMessage = null;
    } catch (e) {
      if (!silent) _errorMessage = 'Failed to load tasks: $e';
    } finally {
      if (!silent) _isLoading = false;
      notifyListeners();
    }
  }

  // Accept assigned task
  Future<bool> acceptTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _taskService.acceptTask(taskId);
    _isLoading = false;

    if (result != null) {
      final idx = _activeTasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _activeTasks[idx] = result;
      } else {
        _activeTasks.add(result);
      }
      _availableTasks.removeWhere((t) => t.id == taskId);
      HapticFeedback.mediumImpact();
      notifyListeners();
      return true;
    }

    // Local fallback update if offline
    final idx = _activeTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _activeTasks[idx].deliveryStatus = 'accepted';
      HapticFeedback.mediumImpact();
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  // Reject task with reason
  Future<bool> rejectTask(String taskId, {required String reason, String? notes}) async {
    _isLoading = true;
    notifyListeners();

    final ok = await _taskService.rejectTask(taskId, reason: reason, notes: notes);
    _isLoading = false;

    if (ok) {
      _activeTasks.removeWhere((t) => t.id == taskId);
      _availableTasks.removeWhere((t) => t.id == taskId);
      _selectedBatchTaskIds.remove(taskId);
      HapticFeedback.lightImpact();
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  // Confirm pantry pickup with checklist
  Future<bool> pickupTask(String taskId, {List<PickupItemChecklist>? checklist}) async {
    _isLoading = true;
    notifyListeners();

    final result = await _taskService.pickupTask(taskId, checklist: checklist);
    _isLoading = false;

    if (result != null) {
      final idx = _activeTasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _activeTasks[idx] = result;
      }
      HapticFeedback.mediumImpact();
      notifyListeners();
      return true;
    }

    // Local update
    final idx = _activeTasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _activeTasks[idx].deliveryStatus = 'picked_up';
      HapticFeedback.mediumImpact();
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  // Batch selection management
  void toggleBatchSelection(String taskId) {
    if (_selectedBatchTaskIds.contains(taskId)) {
      _selectedBatchTaskIds.remove(taskId);
    } else {
      _selectedBatchTaskIds.add(taskId);
    }
    notifyListeners();
  }

  void clearBatchSelection() {
    _selectedBatchTaskIds.clear();
    notifyListeners();
  }

  // Create delivery batch run
  Future<BatchRun?> createBatch({String? tower, String? floor}) async {
    if (_selectedBatchTaskIds.isEmpty) return null;

    _isLoading = true;
    notifyListeners();

    final batch = await _taskService.createBatch(
      _selectedBatchTaskIds.toList(),
      tower: tower,
      floor: floor,
    );

    _isLoading = false;
    if (batch != null) {
      _batches.insert(0, batch);
      _selectedBatchTaskIds.clear();
      HapticFeedback.mediumImpact();
      notifyListeners();
      return batch;
    }

    notifyListeners();
    return null;
  }

  // Update status (e.g. delivered, in_transit)
  Future<bool> updateTaskStatus(String taskId, String status) async {
    final ok = await _taskService.updateStatus(taskId, status);
    if (ok) {
      final idx = _activeTasks.indexWhere((t) => t.id == taskId);
      if (idx != -1) {
        _activeTasks[idx].deliveryStatus = status;
        notifyListeners();
      }
    }
    return ok;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _reassignTicker?.cancel();
    super.dispose();
  }
}
