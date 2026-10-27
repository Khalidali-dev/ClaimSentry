import 'package:flutter/material.dart';
import '../models/preset_claim.dart';
import '../theme/app_theme.dart';

class PresetSelector extends StatelessWidget {
  final List<PresetClaim> presets;
  final PresetClaim? selectedPreset;
  final ValueChanged<PresetClaim> onSelectPreset;

  const PresetSelector({
    super.key,
    required this.presets,
    required this.selectedPreset,
    required this.onSelectPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Pre-loaded Sample Claims',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Select 1 of 3 to Auto-Fill',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: presets.map((preset) {
            final isSelected = selectedPreset?.id == preset.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildPresetCard(preset, isSelected),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPresetCard(PresetClaim preset, bool isSelected) {
    Color badgeColor;
    if (preset.denialCode == 'CO-50') {
      badgeColor = AppColors.cyan;
    } else if (preset.denialCode == 'CO-16') {
      badgeColor = AppColors.warning;
    } else {
      badgeColor = AppColors.indigo;
    }

    return InkWell(
      onTap: () => onSelectPreset(preset),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceElevated
              : AppColors.surfaceVariant.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? badgeColor : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                preset.denialCode,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          preset.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textHighlight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${preset.deniedAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.approved,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'CPT ${preset.deniedCpt} • ${preset.payerName} (${preset.patientName})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? badgeColor : AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
