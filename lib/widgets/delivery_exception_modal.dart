import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/task_models.dart';
import '../providers/task_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class DeliveryExceptionModal extends StatefulWidget {
  final DeliveryTask task;

  const DeliveryExceptionModal({
    super.key,
    required this.task,
  });

  static Future<void> show(BuildContext context, {required DeliveryTask task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DeliveryExceptionModal(task: task),
    );
  }

  @override
  State<DeliveryExceptionModal> createState() => _DeliveryExceptionModalState();
}

class _DeliveryExceptionModalState extends State<DeliveryExceptionModal> {
  final List<String> _reasons = [
    'Customer Unreachable (Phone ringing / no response)',
    'Turnstile / Floor Access Denied by Security',
    'Desk not found / Wrong floor specified',
    'Customer not at desk / In meeting',
    'Meal box damaged / Food spill',
    'Customer cancelled upon arrival',
  ];

  late String _selectedReason;
  bool _isReceptionHandover = false;
  final TextEditingController _receptionistNameController = TextEditingController();
  final TextEditingController _receptionDeskController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedReason = _reasons[0];
  }

  @override
  void dispose() {
    _receptionistNameController.dispose();
    _receptionDeskController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitException() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'reason': _selectedReason,
        'comment': _notesController.text.trim(),
        'handedToReception': _isReceptionHandover,
        'receptionistName': _isReceptionHandover ? _receptionistNameController.text.trim() : '',
        'receptionDesk': _isReceptionHandover ? _receptionDeskController.text.trim() : '',
      };

      await ApiService.post('/delivery/tasks/${widget.task.id}/exception', payload);

      if (_isReceptionHandover) {
        await taskProvider.updateTaskStatus(widget.task.id, 'delivered');
      } else {
        await taskProvider.updateTaskStatus(widget.task.id, 'failed');
      }

      HapticFeedback.mediumImpact();

      if (!mounted) return;
      Navigator.pop(context); // Close sheet

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isReceptionHandover
              ? 'Handover to Reception recorded for #${widget.task.orderNumber}'
              : 'Exception logged. Return meal box to pantry counter.'),
          backgroundColor: _isReceptionHandover ? AppColors.success : AppColors.warning,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit exception: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.report_problem_rounded, color: AppColors.warning, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Exception & Fallback',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Order #${task.orderNumber} • ${task.deliveryDeskInfo.shortLocation}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Structured Exception Reason
              const Text(
                'Select Exception Reason:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              ..._reasons.map((r) {
                final isSelected = _selectedReason == r;
                return InkWell(
                  onTap: () => setState(() => _selectedReason = r),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.4)
                          : (isDark ? AppColors.bgInputDark : AppColors.bgInputLight),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 16,
                          color: isSelected ? AppColors.primary : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            r,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),

              // 2. Reception Handover Toggle (Module D3 requirement)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isReceptionHandover
                      ? AppColors.secondaryLight
                      : (isDark ? AppColors.bgInputDark : AppColors.bgInputLight),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isReceptionHandover ? AppColors.secondary : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Handover to Floor Receptionist',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      subtitle: const Text(
                        'Leaves order securely at front desk / concierge if customer is away',
                        style: TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                      ),
                      value: _isReceptionHandover,
                      activeThumbColor: AppColors.secondary,
                      onChanged: (val) {
                        setState(() => _isReceptionHandover = val);
                        HapticFeedback.selectionClick();
                      },
                    ),
                    if (_isReceptionHandover) ...[
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _receptionistNameController,
                        decoration: const InputDecoration(
                          labelText: "Receptionist's Name *",
                          hintText: 'e.g. Kavitha (Concierge)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _receptionDeskController,
                        decoration: const InputDecoration(
                          labelText: 'Reception Desk Location *',
                          hintText: 'e.g. Floor 4 Main Reception',
                          isDense: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Additional Notes
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Operational Notes (Optional)',
                  hintText: 'e.g. Left parcel with badge security guard...',
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitException,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isReceptionHandover ? AppColors.secondary : AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Icon(_isReceptionHandover ? Icons.meeting_room_rounded : Icons.report_gmailerrorred_rounded),
                  label: Text(
                    _isReceptionHandover ? 'Confirm Reception Handover' : 'Log Delivery Failure & Return to Kiosk',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
