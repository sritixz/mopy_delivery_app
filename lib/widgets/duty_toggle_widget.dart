import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/duty_provider.dart';
import '../theme/app_theme.dart';

class DutyToggleWidget extends StatelessWidget {
  const DutyToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dutyProvider = Provider.of<DutyProvider>(context);

    Color getStatusColor() {
      switch (dutyProvider.dutyStatus) {
        case 'Online':
          return AppColors.statusOnline;
        case 'On Break':
          return AppColors.statusBreak;
        case 'Offline':
        default:
          return AppColors.statusOffline;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: getStatusColor(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: getStatusColor().withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DUTY STATUS: ${dutyProvider.dutyStatus.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: getStatusColor(),
                    ),
                  ),
                ],
              ),
              if (dutyProvider.currentShift != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        dutyProvider.currentShift!.durationString,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // 3-way toggle buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.bgAppDark
                  : AppColors.bgAppLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildOption(
                  context,
                  title: 'Online',
                  icon: Icons.check_circle_outline,
                  isSelected: dutyProvider.isOnline,
                  activeColor: AppColors.statusOnline,
                  onTap: () => dutyProvider.setDutyStatus('Online'),
                ),
                _buildOption(
                  context,
                  title: 'Break',
                  icon: Icons.coffee_outlined,
                  isSelected: dutyProvider.isOnBreak,
                  activeColor: AppColors.statusBreak,
                  onTap: () => dutyProvider.setDutyStatus('On Break'),
                ),
                _buildOption(
                  context,
                  title: 'Offline',
                  icon: Icons.power_settings_new_rounded,
                  isSelected: dutyProvider.isOffline,
                  activeColor: AppColors.statusOffline,
                  onTap: () => dutyProvider.setDutyStatus('Offline'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textMutedLight,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
