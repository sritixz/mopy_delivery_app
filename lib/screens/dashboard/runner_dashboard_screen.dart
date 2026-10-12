import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/duty_provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/duty_toggle_widget.dart';
import '../../widgets/pickup_checklist_sheet.dart';
import '../../widgets/reject_reason_modal.dart';
import '../../widgets/task_card.dart';
import '../delivery/active_delivery_screen.dart';
import '../earnings/earnings_screen.dart';
import '../profile/runner_profile_screen.dart';
import '../tasks/task_queue_screen.dart';

class RunnerDashboardScreen extends StatefulWidget {
  const RunnerDashboardScreen({super.key});

  @override
  State<RunnerDashboardScreen> createState() => _RunnerDashboardScreenState();
}

class _RunnerDashboardScreenState extends State<RunnerDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final duty = Provider.of<DutyProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      if (duty.isOnline) {
        taskProvider.startPolling();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final duty = Provider.of<DutyProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final runner = auth.runner;

    // React to duty changes
    if (duty.isOnline) {
      taskProvider.startPolling();
    } else {
      taskProvider.stopPolling();
    }

    Widget body;
    switch (_currentTabIndex) {
      case 1:
        body = const TaskQueueScreen();
        break;
      case 2:
        body = const EarningsScreen();
        break;
      case 3:
        body = const RunnerProfileScreen();
        break;
      case 0:
      default:
        body = _buildHomeDashboard(context, auth, duty, taskProvider);
    }

    return Scaffold(
      appBar: _currentTabIndex == 0
          ? AppBar(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delivery_dining, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MOPY RUNNER',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.8),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      runner?.name.isNotEmpty == true ? runner!.name[0].toUpperCase() : 'R',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  onPressed: () => setState(() => _currentTabIndex = 3),
                ),
              ],
            )
          : null,
      body: SafeArea(child: body),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (idx) => setState(() => _currentTabIndex = idx),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedLight,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: taskProvider.activeTasks.isNotEmpty,
              label: Text('${taskProvider.activeTasks.length}'),
              child: const Icon(Icons.receipt_long_rounded),
            ),
            label: 'Task Queue',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(
    BuildContext context,
    AuthProvider auth,
    DutyProvider duty,
    TaskProvider taskProvider,
  ) {
    final runner = auth.runner;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Live Duty Toggle Widget
          const DutyToggleWidget(),
          const SizedBox(height: 16),

          // 2. Hub / Kiosk Context Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCardDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.secondary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ASSIGNED PANTRY KIOSK',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        runner?.outletName ?? 'MOPY Central Kitchen - Hub 1',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      Text(
                        runner?.assignedZone != null
                            ? '${runner!.assignedZone!.officeComplex} • ${runner.assignedZone!.buildings.join(", ")}'
                            : 'Embassy Tech Village • Towers A & B',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Runner Shift KPI Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'ACTIVE LOAD',
                  value: '${taskProvider.activeTasks.length}/${runner?.maxCapacity ?? 4}',
                  subtitle: 'Orders in Flight',
                  icon: Icons.shopping_bag_outlined,
                  accentColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'TODAY SLA',
                  value: '98.4%',
                  subtitle: 'On-Time Deliveries',
                  icon: Icons.speed_rounded,
                  accentColor: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Live Duty Status Banner
          if (duty.isOffline)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are currently OFFLINE. Toggle to "Online" above to start receiving desk delivery orders.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMainLight),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.radar_rounded, color: AppColors.success, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Runner Active: Monitoring pantry order queue for Tower A & B desk deliveries.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMainLight),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // 5. Active & Assigned Tasks List Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Assigned Tasks',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              TextButton(
                onPressed: () => setState(() => _currentTabIndex = 1),
                child: const Text('View All Queue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (taskProvider.activeTasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 36, color: AppColors.success.withValues(alpha: 0.8)),
                    const SizedBox(height: 8),
                    const Text('No pending tasks assigned', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text('Check the Available tab to claim new orders', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                  ],
                ),
              ),
            )
          else
            ...taskProvider.activeTasks.take(3).map((task) => TaskCard(
                  task: task,
                  onAccept: () async {
                    await taskProvider.acceptTask(task.id);
                  },
                  onReject: () async {
                    final res = await RejectReasonModal.show(context, orderNumber: task.orderNumber);
                    if (res != null) {
                      await taskProvider.rejectTask(task.id, reason: res['reason']!, notes: res['notes']);
                    }
                  },
                  onPickup: () {
                    PickupChecklistSheet.show(
                      context,
                      task: task,
                      onConfirmPickup: (checklist) async {
                        await taskProvider.pickupTask(task.id, checklist: checklist);
                      },
                    );
                  },
                  onDeliver: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveDeliveryScreen(task: task),
                      ),
                    );
                  },
                )),

          const SizedBox(height: 20),
          // Quick Actions Section
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _currentTabIndex = 1),
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: const Text('Task Queue', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _currentTabIndex = 3),
                  icon: const Icon(Icons.badge_outlined, size: 16),
                  label: const Text('Zone & KYC', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              Icon(icon, size: 16, color: accentColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
          ),
        ],
      ),
    );
  }
}
