import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'document_upload_screen.dart';

class RunnerProfileScreen extends StatelessWidget {
  const RunnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final runner = auth.runner;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Runner Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.bgCardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          runner?.name.isNotEmpty == true ? runner!.name[0].toUpperCase() : 'R',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        child: const Icon(Icons.check, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    runner?.name ?? 'Delivery Runner',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    runner?.phone ?? '+91 98765 12345',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMutedLight),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.two_wheeler_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${runner?.role.toUpperCase() ?? "DELIVERY STAFF"} • ${runner?.vehicleType ?? "ON FOOT"}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Assigned Kiosk & Delivery Zone
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
                  const Row(
                    children: [
                      Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Assigned Kiosk & Complex', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildZoneRow('Kiosk Outlet', runner?.outletName ?? 'MOPY Kiosk #1 - Tech Park Tower B'),
                  _buildZoneRow('Campus / Office', runner?.assignedZone?.officeComplex ?? 'Bandra Tech Park Complex'),
                  _buildZoneRow('Buildings / Towers', runner?.assignedZone?.buildings.join(', ') ?? 'Tower A, Tower B'),
                  _buildZoneRow('Covered Floors', runner?.assignedZone?.floors.join(', ') ?? 'Floor 1, Floor 4, Floor 7, Floor 12'),
                  _buildZoneRow('Max Batch Capacity', '${runner?.maxCapacity ?? 4} orders per run'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KYC Documents Link
            ListTile(
              tileColor: isDark ? AppColors.bgCardDark : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              leading: const Icon(Icons.badge_outlined, color: AppColors.primary),
              title: const Text('Government ID & KYC Proofs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: Text(
                runner?.isVerified == true ? 'Verified by Kiosk Admin' : 'Pending verification',
                style: TextStyle(
                  fontSize: 11,
                  color: runner?.isVerified == true ? AppColors.success : AppColors.warning,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DocumentUploadScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.danger),
              label: const Text('END SHIFT & LOGOUT', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
