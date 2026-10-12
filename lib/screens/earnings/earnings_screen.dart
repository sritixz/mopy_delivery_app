import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/earnings_models.dart';
import '../../providers/duty_provider.dart';
import '../../services/earnings_service.dart';
import '../../theme/app_theme.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  TodayEarnings? _today;
  double _weeklyTotal = 3420.0;
  int _weeklyDeliveries = 72;
  List<EarningsHistoryItem> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEarnings();
  }

  Future<void> _loadEarnings() async {
    setState(() => _isLoading = true);
    final summary = await EarningsService.getEarningsSummary();
    final history = await EarningsService.getEarningsHistory();

    if (mounted) {
      setState(() {
        _today = summary['today'] as TodayEarnings?;
        _weeklyTotal = summary['weeklyTotal'] as double? ?? 3420.0;
        _weeklyDeliveries = summary['weeklyDeliveries'] as int? ?? 72;
        _history = history;
        _isLoading = false;
      });
    }
  }

  void _showEndShiftDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Shift & Clock Out?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
          'Ending your shift will stop incoming order assignments, calculate your total on-duty minutes, and submit today’s payout for night settlement.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final duty = Provider.of<DutyProvider>(context, listen: false);
              final summary = await EarningsService.clockOutShift();
              await duty.setDutyStatus('Offline');
              if (context.mounted && summary != null) {
                _showShiftSummarySlip(context, summary);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Clock Out', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showShiftSummarySlip(BuildContext context, ShiftSummary summary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Shift Completed Successfully',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Great work today! Here is your shift performance summary:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMutedLight),
            ),
            const SizedBox(height: 20),

            // Metrics grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgInputDark : AppColors.bgInputLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSlipRow('Shift Duration', '${(summary.totalOnlineMinutes / 60).toStringAsFixed(1)} hrs'),
                  const Divider(height: 16),
                  _buildSlipRow('Orders Delivered', '${summary.totalDeliveries} meal boxes'),
                  const Divider(height: 16),
                  _buildSlipRow('On-Time SLA Rate', '${summary.slaRate.toStringAsFixed(1)}%'),
                  const Divider(height: 16),
                  _buildSlipRow('Net Shift Earnings', '₹${summary.netEarnings.toStringAsFixed(0)}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisputeModal(BuildContext context) {
    String selectedReason = 'Missing Order Payout';
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCardDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Raise Payout Dispute Ticket',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Report any discrepancy with your delivery fees or incentives.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMutedLight),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  decoration: const InputDecoration(labelText: 'Dispute Reason'),
                  items: [
                    'Missing Order Payout',
                    'Batch Bonus Not Added',
                    'Excess Distance Not Compensated',
                    'Incorrect Shift Penalty',
                  ].map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) selectedReason = val;
                  },
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Details / Order Number',
                    hintText: 'e.g. Order #MPY-8492 delivery fee not credited...',
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final ticketId = await EarningsService.raiseDispute(
                        reason: selectedReason,
                        notes: notesController.text.trim(),
                      );
                      if (context.mounted && ticketId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ticket #$ticketId opened. Ops team will investigate.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Submit Dispute', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlipRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isBold ? null : AppColors.textMutedLight)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isBold ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = _today ?? TodayEarnings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings & Settlements', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Raise Dispute',
            onPressed: () => _showDisputeModal(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadEarnings,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Today's Net Payout Hero Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE31B23), Color(0xFFC7121A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TODAY'S ESTIMATED PAYOUT",
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  today.settlementStatus.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹${today.netEarnings.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${today.deliveriesCount} Corporate Drops Completed Today',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Earnings Breakdown Card
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
                          const Text(
                            'Earnings Breakdown',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(height: 14),
                          _buildBreakdownRow(
                            'Base Shift Guarantee',
                            '₹${today.baseShiftPay.toStringAsFixed(0)}',
                            icon: Icons.shield_outlined,
                          ),
                          const Divider(height: 16),
                          _buildBreakdownRow(
                            'Delivery Fees (${today.deliveriesCount} drops x ₹30)',
                            '₹${today.perOrderPay.toStringAsFixed(0)}',
                            icon: Icons.delivery_dining_rounded,
                          ),
                          const Divider(height: 16),
                          _buildBreakdownRow(
                            'Multi-Order Batch Bonus',
                            '₹${today.batchBonus.toStringAsFixed(0)}',
                            icon: Icons.layers_rounded,
                          ),
                          const Divider(height: 16),
                          _buildBreakdownRow(
                            'Customer Tips',
                            '₹${today.tips.toStringAsFixed(0)}',
                            icon: Icons.volunteer_activism_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Weekly Summary Banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bgCardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'THIS WEEK TOTAL',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMutedLight),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${_weeklyTotal.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '$_weeklyDeliveries Deliveries',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. End Shift Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showEndShiftDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.bgCardDark : Colors.white,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.access_time_rounded),
                        label: const Text('End Shift & Clock Out', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 5. Past Settlements History
                    const Text(
                      'Past Settlements History',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                    const SizedBox(height: 10),

                    ..._history.map((item) {
                      final dateStr = DateFormat('EEE, dd MMM yyyy').format(item.date);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        elevation: 0,
                        color: isDark ? AppColors.bgCardDark : Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.deliveriesCount} deliveries',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '₹${item.netEarnings.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: item.settlementStatus == 'Settled'
                                          ? AppColors.successLight
                                          : AppColors.warningLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.settlementStatus,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: item.settlementStatus == 'Settled'
                                            ? AppColors.success
                                            : AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }
}
