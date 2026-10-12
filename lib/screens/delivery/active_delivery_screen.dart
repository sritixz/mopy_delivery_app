import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/task_models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/delivery_exception_modal.dart';
import 'pod_capture_screen.dart';

class ActiveDeliveryScreen extends StatefulWidget {
  final DeliveryTask task;

  const ActiveDeliveryScreen({
    super.key,
    required this.task,
  });

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  Timer? _timer;
  late int _remainingSlaMinutes;

  @override
  void initState() {
    super.initState();
    _remainingSlaMinutes = widget.task.remainingSlaMinutes;
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _remainingSlaMinutes = widget.task.remainingSlaMinutes;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _maskPhone(String phone) {
    if (phone.length <= 6) return phone;
    return '${phone.substring(0, 6)} •••••';
  }

  Future<void> _makeCustomerCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Simulated Call: Dialing $phone...'),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulated Call: Connecting to $phone'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  void _showSmsTemplatesModal(BuildContext context, String customerName) {
    final templates = [
      'Hi $customerName, I have arrived at your floor with your MOPY order.',
      'Hi $customerName, I am at your desk now.',
      'Hi $customerName, please collect your meal box from Floor Reception.',
      'Hi $customerName, unable to access your floor turnstile. Could you please assist?',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.bgCardDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Customer Messages',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...templates.map((msg) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary, size: 20),
                    title: Text(msg, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Message sent to $customerName!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;
    final desk = task.deliveryDeskInfo;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Active Delivery #${task.orderNumber}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            Text(
              '${task.items.length} items • ₹${task.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
            tooltip: 'Report Exception',
            onPressed: () {
              DeliveryExceptionModal.show(context, task: task);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SLA Countdown Urgency Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _remainingSlaMinutes <= 5
                      ? AppColors.error.withValues(alpha: 0.12)
                      : (_remainingSlaMinutes <= 15
                          ? AppColors.warning.withValues(alpha: 0.12)
                          : AppColors.success.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _remainingSlaMinutes <= 5
                        ? AppColors.error
                        : (_remainingSlaMinutes <= 15 ? AppColors.warning : AppColors.success),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      color: _remainingSlaMinutes <= 5
                          ? AppColors.error
                          : (_remainingSlaMinutes <= 15 ? AppColors.warning : AppColors.success),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _remainingSlaMinutes > 0
                                ? '$_remainingSlaMinutes MINUTES REMAINING'
                                : 'SLA DEADLINE OVERDUE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: _remainingSlaMinutes <= 5
                                  ? AppColors.error
                                  : (_remainingSlaMinutes <= 15 ? AppColors.warning : AppColors.success),
                            ),
                          ),
                          const Text(
                            'Maintain on-time corporate delivery for full batch payout',
                            style: TextStyle(fontSize: 10, color: AppColors.textMutedLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Indoor Campus & Desk Breadcrumbs (Module D3)
              const Text(
                'Indoor Navigation Route',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildRouteStep(
                      step: '1',
                      title: 'Campus Campus Hub',
                      detail: 'Embassy TechVillage • Gate #2 Pass',
                      icon: Icons.domain_rounded,
                      isCompleted: true,
                    ),
                    _buildStepDivider(),
                    _buildRouteStep(
                      step: '2',
                      title: '${desk.tower} Entrance',
                      detail: 'Lobby Turnstile • Badge In at Security',
                      icon: Icons.login_rounded,
                      isCompleted: true,
                    ),
                    _buildStepDivider(),
                    _buildRouteStep(
                      step: '3',
                      title: '${desk.floor} via Lift',
                      detail: 'Elevator Bank B • Bay 4 West Wing',
                      icon: Icons.elevator_rounded,
                      isCurrent: true,
                    ),
                    _buildStepDivider(),
                    _buildRouteStep(
                      step: '4',
                      title: desk.deskNumber.isNotEmpty ? desk.deskNumber : 'Employee Desk',
                      detail: '${desk.department.isNotEmpty ? '${desk.department} • ' : ''}Target Drop Spot',
                      icon: Icons.pin_drop_rounded,
                      isTarget: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Building Access Instructions Card
              if (desk.buildingAccessInstructions.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BUILDING ACCESS NOTES',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.secondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              desk.buildingAccessInstructions,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Masked Customer Contact Card
              Container(
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
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryLight,
                          child: Text(
                            task.customerName.isNotEmpty ? task.customerName[0].toUpperCase() : 'C',
                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.customerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                              Text(_maskPhone(task.customerPhone), style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _makeCustomerCall(task.customerPhone),
                            icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                            label: const Text('Call (Masked)', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.secondary,
                              side: const BorderSide(color: AppColors.secondary),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showSmsTemplatesModal(context, task.customerName),
                            icon: const Icon(Icons.sms_outlined, size: 16),
                            label: const Text('Send SMS', style: TextStyle(fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PodCaptureScreen(task: task),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text(
                    'Arrived at Desk: Take PoD Photo',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    DeliveryExceptionModal.show(context, task: task);
                  },
                  icon: const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.textMutedLight),
                  label: const Text(
                    'Unable to reach desk? Handover to Reception',
                    style: TextStyle(fontSize: 12, color: AppColors.textMutedLight, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteStep({
    required String step,
    required String title,
    required String detail,
    required IconData icon,
    bool isCompleted = false,
    bool isCurrent = false,
    bool isTarget = false,
  }) {
    Color stepColor = AppColors.textMutedLight;
    if (isCompleted) stepColor = AppColors.success;
    if (isCurrent) stepColor = AppColors.secondary;
    if (isTarget) stepColor = AppColors.primary;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: stepColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: stepColor, width: 1.5),
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check : icon,
              size: 16,
              color: stepColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: isTarget ? AppColors.primary : null,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 15, top: 4, bottom: 4),
      height: 18,
      width: 2,
      color: Colors.grey.withValues(alpha: 0.3),
    );
  }
}
