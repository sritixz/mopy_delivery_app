import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RejectReasonModal extends StatefulWidget {
  final String orderNumber;

  const RejectReasonModal({
    super.key,
    required this.orderNumber,
  });

  static Future<Map<String, String>?> show(BuildContext context, {required String orderNumber}) {
    return showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RejectReasonModal(orderNumber: orderNumber),
    );
  }

  @override
  State<RejectReasonModal> createState() => _RejectReasonModalState();
}

class _RejectReasonModalState extends State<RejectReasonModal> {
  final List<String> _reasons = [
    'Overloaded (At maximum carry capacity)',
    'Vehicle breakdown / Mobility issue',
    'Off Duty / Shift ending soon',
    'Out of assigned delivery zone',
    'Restricted floor / Security access denied',
    'Food damaged or spill at counter',
    'Other reason',
  ];

  String _selectedReason = 'Overloaded (At maximum carry capacity)';
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined, color: AppColors.error, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reject Order Assignment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Order #${widget.orderNumber}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Please select a reason for declining this order:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Reasons Radio List
              ..._reasons.map((r) {
                final isSelected = _selectedReason == r;
                return InkWell(
                  onTap: () => setState(() => _selectedReason = r),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.5)
                          : (isDark ? AppColors.bgInputDark : AppColors.bgInputLight),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          color: isSelected ? AppColors.primary : AppColors.textMutedLight,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
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

              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'e.g. Floor elevator under maintenance...',
                ),
              ),
              const SizedBox(height: 16),

              // Notice
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This order will be automatically reassigned to another available runner on campus.',
                        style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'reason': _selectedReason,
                          'notes': _notesController.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
