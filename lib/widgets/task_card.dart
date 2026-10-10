import 'package:flutter/material.dart';
import '../models/task_models.dart';
import '../theme/app_theme.dart';

class TaskCard extends StatefulWidget {
  final DeliveryTask task;
  final bool isSelectable;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onPickup;
  final VoidCallback? onDeliver;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.isSelectable = false,
    this.isSelected = false,
    this.onSelectChanged,
    this.onAccept,
    this.onReject,
    this.onPickup,
    this.onDeliver,
    this.onTap,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;

  Color _getSlaColor(int minutes) {
    if (minutes <= 5) return AppColors.error;
    if (minutes <= 15) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = widget.task;
    final remainingSecs = task.remainingSecondsToReassign;
    final slaMinutes = task.remainingSlaMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isSelected
              ? AppColors.primary
              : (task.isPriority ? AppColors.primary.withValues(alpha: 0.4) : (isDark ? AppColors.borderDark : AppColors.borderLight)),
          width: widget.isSelected ? 2 : 1,
        ),
      ),
      elevation: widget.isSelected ? 4 : 0,
      color: isDark ? AppColors.bgCardDark : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap ?? () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Badges Row
              Row(
                children: [
                  if (widget.isSelectable)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Checkbox(
                        value: widget.isSelected,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: widget.onSelectChanged,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgInputDark : AppColors.bgInputLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${task.orderNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (task.isPriority)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PRIORITY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // SLA Timer Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getSlaColor(slaMinutes).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined, size: 12, color: _getSlaColor(slaMinutes)),
                        const SizedBox(width: 4),
                        Text(
                          slaMinutes > 0 ? '${slaMinutes}m SLA' : 'SLA Overdue',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: _getSlaColor(slaMinutes),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 2. Corporate Desk Location Card
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.apartment_rounded, size: 16, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            task.deliveryDeskInfo.shortLocation,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                        if (task.deliveryDeskInfo.department.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.deliveryDeskInfo.department,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ),
                      ],
                    ),
                    if (task.deliveryDeskInfo.buildingAccessInstructions.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 12, color: AppColors.textMutedLight),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task.deliveryDeskInfo.buildingAccessInstructions,
                              style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // 3. Customer & Pantry context
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textMutedLight),
                      const SizedBox(width: 4),
                      Text(
                        task.customerName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.storefront_outlined, size: 14, color: AppColors.textMutedLight),
                      const SizedBox(width: 4),
                      Text(
                        task.outletName,
                        style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 4. Items summary & Expand/Collapse
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${task.totalItemCount} items • ₹${task.totalAmount.toStringAsFixed(0)} (${task.paymentStatus})',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isExpanded ? 'Hide items' : 'View items',
                          style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Expanded Items Drawer
              if (_isExpanded) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 6),
                ...task.items.map((it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${it.quantity}x ${it.name}', style: const TextStyle(fontSize: 11)),
                          Text('₹${(it.price * it.quantity).toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
              ],

              // 5. Assigned 60-Second Auto-Reassign Countdown Bar
              if (task.deliveryStatus == 'assigned') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: remainingSecs <= 15
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_top_rounded,
                        size: 14,
                        color: remainingSecs <= 15 ? AppColors.error : AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          remainingSecs > 0
                              ? 'Auto-reassigns in $remainingSecs seconds'
                              : 'Reassignment in progress...',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: remainingSecs <= 15 ? AppColors.error : AppColors.warning,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          value: remainingSecs > 0 ? (remainingSecs / 60.0).clamp(0.0, 1.0) : 0.0,
                          strokeWidth: 2.2,
                          color: remainingSecs <= 15 ? AppColors.error : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 6. Action Buttons
              const SizedBox(height: 12),
              if (task.deliveryStatus == 'assigned')
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: widget.onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: widget.onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text('Accept Order', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ),
                  ],
                )
              else if (task.deliveryStatus == 'accepted')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onPickup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined, size: 16),
                    label: const Text('Verify Counter Pickup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                )
              else if (task.deliveryStatus == 'picked_up' || task.deliveryStatus == 'in_transit')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onDeliver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.navigation_outlined, size: 16),
                    label: const Text('Navigate to Desk & Deliver', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                )
              else if (task.deliveryStatus == 'unassigned')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onAccept,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add_task_rounded, size: 16),
                    label: const Text('Claim This Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
