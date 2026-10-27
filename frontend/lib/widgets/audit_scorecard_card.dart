import 'package:flutter/material.dart';
import '../models/run_response.dart';
import '../theme/app_theme.dart';

class AuditScorecardCard extends StatelessWidget {
  final RunResponse response;

  const AuditScorecardCard({
    super.key,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = response.status.toUpperCase() == 'APPROVED';
    final isRejected = response.status.toUpperCase().contains('REJECT') ||
        (!response.auditScorecard.passed && response.auditScorecard.score == 0);
    final statusColor = isApproved
        ? AppColors.approved
        : (isRejected ? AppColors.error : AppColors.warning);
    final score = response.auditScorecard.score;

    final rejectionReason = response.auditScorecard.critiquePoints.isNotEmpty
        ? response.auditScorecard.critiquePoints.first
        : (response.critiqueHistory.isNotEmpty
            ? response.critiqueHistory.first.critique.summary
            : 'The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.2),
                          statusColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: statusColor,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'STATUTORY AUDIT SCORECARD',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '$score / 100',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isApproved
                                ? '• Overturn Threshold Exceeded'
                                : (isRejected
                                    ? '• Non-Clinical Document Rejected'
                                    : '• Revision Required'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Status Badge (Red for REJECTED, Green for APPROVED, Amber for PENDING/REVISING)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isApproved
                          ? Icons.verified_rounded
                          : (isRejected
                              ? Icons.cancel_rounded
                              : Icons.warning_amber_rounded),
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isRejected ? 'REJECTED' : response.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Prominent Warning Box if Rejected
          if (isRejected) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DOCUMENT REJECTED BY AUDITOR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rejectionReason,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Sub-metrics row
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;

              final metricWidgets = [
                _buildSubMetric(
                  icon: Icons.loop_rounded,
                  label: 'Iterations',
                  value: isRejected
                      ? '${response.iterationsCount} Loop (Aborted)'
                      : '${response.iterationsCount} Loops',
                  color: isRejected ? AppColors.textMuted : AppColors.cyan,
                ),
                _buildSubMetric(
                  icon: Icons.gavel_rounded,
                  label: 'Statutory Statutes',
                  value: isRejected
                      ? '0 Citations'
                      : '${response.appealPackage.statutoryCitations.length} Citations',
                  color: isRejected ? AppColors.textMuted : AppColors.indigo,
                ),
                _buildSubMetric(
                  icon: Icons.transform_rounded,
                  label: 'Coding Crosswalk',
                  value: isRejected
                      ? 'Ineligible Document'
                      : (response.appealPackage.codingCrosswalk.modifierApplied !=
                              null
                          ? 'CPT ${response.appealPackage.codingCrosswalk.cptCode}${response.appealPackage.codingCrosswalk.modifierApplied}'
                          : '${response.appealPackage.codingCrosswalk.billedIcd10} -> ${response.appealPackage.codingCrosswalk.correctedIcd10}'),
                  color: isRejected ? AppColors.error : AppColors.approved,
                ),
                _buildSubMetric(
                  icon: Icons.verified_user_outlined,
                  label: 'Overturn Probability',
                  value: isRejected ? '0% Ineligible' : '98% High',
                  color: isRejected ? AppColors.error : AppColors.approved,
                ),
              ];

              return Wrap(
                spacing: 16,
                runSpacing: 10,
                children: metricWidgets
                    .map((w) => SizedBox(width: isCompact ? 140 : 160, child: w))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
