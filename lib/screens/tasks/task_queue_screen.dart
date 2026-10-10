import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pickup_checklist_sheet.dart';
import '../../widgets/reject_reason_modal.dart';
import '../../widgets/task_card.dart';

class TaskQueueScreen extends StatefulWidget {
  const TaskQueueScreen({super.key});

  @override
  State<TaskQueueScreen> createState() => _TaskQueueScreenState();
}

class _TaskQueueScreenState extends State<TaskQueueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBatchSelectionMode = false;
  String _selectedTowerFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeCount = taskProvider.activeTasks.length;
    final availableCount = taskProvider.availableTasks.length;
    final batchCount = taskProvider.batches.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Task Queue', style: TextStyle(fontWeight: FontWeight.w900)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMutedLight,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('My Active'),
                  if (activeCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Available'),
                  if (availableCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$availableCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Batches'),
                  if (batchCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.textMutedLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$batchCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. ACTIVE / ASSIGNED TAB
          _buildActiveTab(taskProvider),

          // 2. AVAILABLE QUEUE TAB
          _buildAvailableTab(taskProvider),

          // 3. BATCH RUNS TAB
          _buildBatchesTab(taskProvider),
        ],
      ),
      bottomNavigationBar: _isBatchSelectionMode && taskProvider.selectedBatchTaskIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${taskProvider.selectedBatchTaskIds.length} Orders Selected',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const Text(
                            'Grouped for same tower delivery',
                            style: TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final batch = await taskProvider.createBatch(tower: 'Tower B', floor: 'Floor 4');
                        if (batch != null && mounted) {
                          setState(() => _isBatchSelectionMode = false);
                          _tabController.animateTo(2); // Jump to batches tab
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Batch #${batch.batchNumber} created with ${batch.totalOrders} orders!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.layers_rounded, size: 18),
                      label: const Text('Create Batch Run', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // 1. ACTIVE TAB CONTENT
  Widget _buildActiveTab(TaskProvider taskProvider) {
    if (taskProvider.activeTasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.checklist_rtl_rounded,
        title: 'No active orders right now',
        subtitle: 'New assigned orders will show up here with 60-second priority alerts.',
        buttonText: 'Check Available Queue',
        onTap: () => _tabController.animateTo(1),
      );
    }

    return RefreshIndicator(
      onRefresh: () => taskProvider.fetchTasks(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: taskProvider.activeTasks.length,
        itemBuilder: (_, index) {
          final task = taskProvider.activeTasks[index];
          return TaskCard(
            task: task,
            onAccept: () async {
              final ok = await taskProvider.acceptTask(task.id);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order #${task.orderNumber} accepted! Proceed to kitchen counter.'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            onReject: () async {
              final res = await RejectReasonModal.show(context, orderNumber: task.orderNumber);
              if (res != null) {
                await taskProvider.rejectTask(task.id, reason: res['reason']!, notes: res['notes']);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assignment declined. Order returned to pool.'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                }
              }
            },
            onPickup: () {
              PickupChecklistSheet.show(
                context,
                task: task,
                onConfirmPickup: (checklist) async {
                  await taskProvider.pickupTask(task.id, checklist: checklist);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Pickup verified for #${task.orderNumber}! Heading to desk.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              );
            },
            onDeliver: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Starting navigation to ${task.deliveryDeskInfo.shortLocation}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 2. AVAILABLE TAB CONTENT
  Widget _buildAvailableTab(TaskProvider taskProvider) {
    final filtered = _selectedTowerFilter == 'All'
        ? taskProvider.availableTasks
        : taskProvider.availableTasks.where((t) => t.deliveryDeskInfo.tower == _selectedTowerFilter).toList();

    return Column(
      children: [
        // Filter & Batch Toggle Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.bgCardDark : Colors.white,
            border: Border(bottom: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight)),
          ),
          child: Row(
            children: [
              // Tower Filter Chips
              Wrap(
                spacing: 6,
                children: ['All', 'Tower A', 'Tower B'].map((tower) {
                  final isSelected = _selectedTowerFilter == tower;
                  return ChoiceChip(
                    label: Text(tower, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight,
                    onSelected: (val) {
                      if (val) setState(() => _selectedTowerFilter = tower);
                    },
                  );
                }).toList(),
              ),
              const Spacer(),
              // Batch Toggle Button
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isBatchSelectionMode = !_isBatchSelectionMode;
                    if (!_isBatchSelectionMode) taskProvider.clearBatchSelection();
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: _isBatchSelectionMode ? AppColors.primaryLight : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  _isBatchSelectionMode ? Icons.check_box_rounded : Icons.layers_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: Text(
                  _isBatchSelectionMode ? 'Cancel Batch' : 'Batch Multi',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        // Task List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(
                  icon: Icons.hourglass_empty_rounded,
                  title: 'No available orders in this tower',
                  subtitle: 'All orders have been picked up or assigned to active runners.',
                  buttonText: 'Refresh Pool',
                  onTap: () => taskProvider.fetchTasks(),
                )
              : RefreshIndicator(
                  onRefresh: () => taskProvider.fetchTasks(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, index) {
                      final task = filtered[index];
                      final isSelected = taskProvider.selectedBatchTaskIds.contains(task.id);

                      return TaskCard(
                        task: task,
                        isSelectable: _isBatchSelectionMode,
                        isSelected: isSelected,
                        onSelectChanged: (val) {
                          taskProvider.toggleBatchSelection(task.id);
                        },
                        onAccept: () async {
                          final ok = await taskProvider.acceptTask(task.id);
                          if (ok && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Order #${task.orderNumber} claimed successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _tabController.animateTo(0);
                          }
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // 3. BATCHES TAB CONTENT
  Widget _buildBatchesTab(TaskProvider taskProvider) {
    if (taskProvider.batches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.layers_outlined,
        title: 'No active batch runs',
        subtitle: 'Group multiple orders going to the same tower/floor into a single batch to maximize your payout.',
        buttonText: 'Create Batch from Available',
        onTap: () {
          setState(() => _isBatchSelectionMode = true);
          _tabController.animateTo(1);
        },
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: taskProvider.batches.length,
      itemBuilder: (_, index) {
        final batch = taskProvider.batches[index];
        final progress = batch.totalOrders > 0 ? (batch.completedOrders / batch.totalOrders) : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          elevation: 0,
          color: isDark ? AppColors.bgCardDark : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.layers_rounded, color: AppColors.secondary, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          batch.batchNumber,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${batch.orders.length} Orders Batch',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location route
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgInputDark : AppColors.bgInputLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment_rounded, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Destination: ${batch.tower} • ${batch.floor}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Progress (${batch.completedOrders}/${batch.totalOrders})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark ? Colors.white12 : Colors.black12,
                  color: AppColors.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 14),

                // Orders in this batch
                ...batch.orders.map((o) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '#${o.orderNumber} - ${o.deliveryDeskInfo.deskNumber} (${o.customerName})',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text('₹${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Starting sequential run for ${batch.batchNumber}'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.directions_walk_rounded, size: 16),
                    label: const Text('Execute Batch Run', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Generic empty state
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
