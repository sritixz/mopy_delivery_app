import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  String _selectedDocType = 'Aadhaar Card';
  String _selectedVehicle = 'Bicycle Express';
  bool _isSaving = false;

  final List<String> _docTypes = ['Aadhaar Card', 'Driving License', 'PAN Card', 'Voter ID'];
  final List<String> _vehicles = ['On Foot (Indoor Hub)', 'Bicycle Express', 'E-Scooter', 'Motorcycle'];

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('KYC Documents Submitted for Admin Verification'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Runner KYC & Documents'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: auth.runner?.isVerified == true
                    ? AppColors.successLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: auth.runner?.isVerified == true
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    auth.runner?.isVerified == true
                        ? Icons.verified_rounded
                        : Icons.pending_actions_rounded,
                    color: auth.runner?.isVerified == true
                        ? AppColors.success
                        : AppColors.warning,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.runner?.isVerified == true
                              ? 'VERIFIED PARTNER STATUS'
                              : 'PENDING ADMIN APPROVAL',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: auth.runner?.isVerified == true
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.runner?.isVerified == true
                              ? 'Your staff documents are verified. You are authorized for desk delivery.'
                              : 'Your documents are under review by the Kiosk Operations team.',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Government ID Proof',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Select document type
            DropdownButtonFormField<String>(
              initialValue: _selectedDocType,
              items: _docTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDocType = val);
              },
              decoration: InputDecoration(
                labelText: 'Document Type',
                filled: true,
                fillColor: isDark ? AppColors.bgCardDark : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Document upload card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.file_present_rounded, color: AppColors.primary, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_selectedDocType Uploaded', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          const Text('aadhaar_front_back.pdf (1.2 MB)', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Re-uploading new document...')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('REPLACE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Profile Photo / ID Card',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Runner Badge Selfie', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('partner_badge_selfie.jpg (800 KB)', style: TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Capturing new camera photo...')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('UPDATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Delivery Vehicle / Mode',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _selectedVehicle,
              items: _vehicles.map((v) {
                return DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedVehicle = val);
              },
              decoration: InputDecoration(
                labelText: 'Delivery Mode',
                filled: true,
                fillColor: isDark ? AppColors.bgCardDark : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('SAVE & UPDATE KYC'),
            ),
          ],
        ),
      ),
    );
  }
}
