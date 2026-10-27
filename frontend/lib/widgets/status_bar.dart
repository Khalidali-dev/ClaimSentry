import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../theme/app_theme.dart';

class StatusBar extends StatelessWidget {
  final bool isBackendHealthy;
  final String meterlessStatus;
  final String zetarisStatus;
  final String? apiEndpoint;

  const StatusBar({
    super.key,
    required this.isBackendHealthy,
    this.meterlessStatus = 'Port 8088 (Online / Fallback Ready)',
    this.zetarisStatus = 'Port 8888 (Billing Rules Cached)',
    this.apiEndpoint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 1150;
          if (isSmall) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildDaemonItem(
                      icon: Icons.memory,
                      label: 'Meterless Daemon',
                      value: meterlessStatus,
                      isOnline: true,
                      color: AppColors.cyan,
                    ),
                    _buildDaemonItem(
                      icon: Icons.hub_outlined,
                      label: 'Zetaris Data Layer',
                      value: zetarisStatus,
                      isOnline: true,
                      color: AppColors.indigo,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.route_outlined,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Target: ${apiEndpoint ?? "POST ${AppConfig.runEndpoint}"}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildDaemonItem(
                      icon: Icons.memory,
                      label: 'Meterless Daemon',
                      value: meterlessStatus,
                      isOnline: true,
                      color: AppColors.cyan,
                    ),
                    _buildDaemonItem(
                      icon: Icons.hub_outlined,
                      label: 'Zetaris Data Layer',
                      value: zetarisStatus,
                      isOnline: true,
                      color: AppColors.indigo,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.route_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Target: ${apiEndpoint ?? "POST ${AppConfig.runEndpoint}"}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaemonItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isOnline,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.approved : AppColors.warning,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isOnline
                    ? AppColors.approved.withValues(alpha: 0.6)
                    : AppColors.warning.withValues(alpha: 0.6),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
