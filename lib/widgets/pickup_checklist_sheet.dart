import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task_models.dart';
import '../theme/app_theme.dart';

class PickupChecklistSheet extends StatefulWidget {
  final DeliveryTask task;
  final Future<void> Function(List<PickupItemChecklist> checklist) onConfirmPickup;

  const PickupChecklistSheet({
    super.key,
    required this.task,
    required this.onConfirmPickup,
  });

  static Future<void> show(
    BuildContext context, {
    required DeliveryTask task,
    required Future<void> Function(List<PickupItemChecklist> checklist) onConfirmPickup,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PickupChecklistSheet(task: task, onConfirmPickup: onConfirmPickup),
    );
  }

  @override
  State<PickupChecklistSheet> createState() => _PickupChecklistSheetState();
}

class _PickupChecklistSheetState extends State<PickupChecklistSheet> {
  late List<PickupItemChecklist> _checklist;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checklist = widget.task.pickupChecklist.map((c) => PickupItemChecklist(
      itemId: c.itemId,
      name: c.name,
      quantity: c.quantity,
      isPacked: c.isPacked,
      notes: c.notes,
    )).toList();
  }

  bool get _allChecked => _checklist.every((c) => c.isPacked);

  void _markAllChecked() {
    setState(() {
      final target = !_allChecked;
      for (final item in _checklist) {
        item.isPacked = target;
      }
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgCardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2_rounded, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pantry Counter Pickup Checklist',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Order #${task.orderNumber} • ${task.outletName}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Instructions banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgInputDark : AppColors.bgInputLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Check off each item at the kitchen pass before leaving to ensure zero customer complaints.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton(
                  onPressed: _markAllChecked,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(_allChecked ? 'Uncheck All' : 'Check All', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Checklist items
          Expanded(
            child: ListView.separated(
              itemCount: _checklist.length,
              separatorBuilder: (ctx, idx) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _checklist[index];
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: item.isPacked ? TextDecoration.lineThrough : null,
                      color: item.isPacked ? AppColors.textMutedLight : null,
                    ),
                  ),
                  subtitle: Text(
                    'Quantity: ${item.quantity}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                  ),
                  value: item.isPacked,
                  activeColor: AppColors.secondary,
                  onChanged: (val) {
                    setState(() => item.isPacked = val ?? false);
                    HapticFeedback.selectionClick();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          // Destination reminder
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.navigation_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Deliver to: ${task.deliveryDeskInfo.shortLocation} (${task.customerName})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_allChecked && !_isSubmitting)
                  ? () async {
                      final nav = Navigator.of(context);
                      setState(() => _isSubmitting = true);
                      await widget.onConfirmPickup(_checklist);
                      nav.pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.done_all_rounded),
              label: Text(
                _allChecked ? 'Confirm Pickup & Start Delivery' : 'Check all items to confirm (${_checklist.where((c) => c.isPacked).length}/${_checklist.length})',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
