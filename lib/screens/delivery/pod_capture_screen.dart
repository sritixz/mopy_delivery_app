import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/task_models.dart';
import '../../providers/task_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class PodCaptureScreen extends StatefulWidget {
  final DeliveryTask task;

  const PodCaptureScreen({
    super.key,
    required this.task,
  });

  @override
  State<PodCaptureScreen> createState() => _PodCaptureScreenState();
}

class _PodCaptureScreenState extends State<PodCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  String? _base64Image;
  String _handoverType = 'Placed on Customer Desk';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _colleagueController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    _colleagueController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final photo = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _capturedImage = photo;
          _base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        });
        HapticFeedback.mediumImpact();
      }
    } catch (_) {
      // Simulator fallback: simulate captured photo
      setState(() {
        _base64Image = 'data:image/jpeg;base64,simulated_desk_drop_photo';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Simulated Desk Photo captured.')),
        );
      }
    }
  }

  Future<void> _submitProof() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'photoUrl': _base64Image ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
        'dropSpotNotes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : 'Dropped at ${widget.task.deliveryDeskInfo.shortLocation}',
        'handoverType': _handoverType,
        'receivedBy': _handoverType == 'Handed to Colleague'
            ? _colleagueController.text.trim()
            : widget.task.customerName,
      };

      // Call API
      await ApiService.post('/delivery/tasks/${widget.task.id}/proof', payload);

      // Update provider status
      await taskProvider.updateTaskStatus(widget.task.id, 'delivered');
      HapticFeedback.heavyImpact();

      if (!mounted) return;

      // Show Success Dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delivery Completed!',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Order #${widget.task.orderNumber} delivered to ${widget.task.deliveryDeskInfo.shortLocation}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.monetization_on_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      '+ ₹30 Delivery Payout Earned',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Close dialog
                    Navigator.pop(context); // Close PoD screen
                    Navigator.pop(context); // Close ActiveDeliveryScreen
                  },
                  child: const Text('Back to Queue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting proof: $e'), backgroundColor: AppColors.error),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proof of Delivery (PoD)', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Target Desk Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.bgCardDark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pin_drop_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.deliveryDeskInfo.shortLocation,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          Text(
                            'Recipient: ${task.customerName} (#${task.orderNumber})',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 1. Camera Desk Photo Box
              const Text(
                '1. Desk Drop Photo Capture',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 4),
              const Text(
                'Take a clear photo showing the meal box at the employee desk.',
                style: TextStyle(fontSize: 11, color: AppColors.textMutedLight),
              ),
              const SizedBox(height: 10),

              InkWell(
                onTap: () => _capturePhoto(ImageSource.camera),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgInputDark : AppColors.bgInputLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _base64Image != null ? AppColors.success : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      width: _base64Image != null ? 2 : 1,
                    ),
                  ),
                  child: _capturedImage != null && !kIsWeb
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Retake', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : (_base64Image != null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, size: 40, color: AppColors.success),
                                  SizedBox(height: 8),
                                  Text('Desk photo recorded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded, size: 32, color: AppColors.primary),
                                ),
                                const SizedBox(height: 10),
                                const Text('Tap to open camera & take photo', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                const SizedBox(height: 4),
                                const Text('or select from gallery', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                              ],
                            )),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Handover Type Radio Options
              const Text(
                '2. Handover Method',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 8),

              ...['Placed on Customer Desk', 'Handed directly to Customer', 'Handed to Colleague'].map((type) {
                final isSelected = _handoverType == type;
                return InkWell(
                  onTap: () => setState(() => _handoverType = type),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight.withValues(alpha: 0.4)
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
                        Text(
                          type,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected ? AppColors.primary : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              if (_handoverType == 'Handed to Colleague') ...[
                const SizedBox(height: 4),
                TextField(
                  controller: _colleagueController,
                  decoration: const InputDecoration(
                    labelText: "Colleague's Name / Desk ID",
                    hintText: 'e.g. Suresh (Desk 414)',
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 3. Drop Spot Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Desk Spot Notes (Optional)',
                  hintText: 'e.g. Left on table next to monitor...',
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitProof,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.verified_rounded),
                  label: const Text(
                    'Confirm Proof & Complete Delivery',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
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
