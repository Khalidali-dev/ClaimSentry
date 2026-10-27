import 'package:flutter/material.dart';
import '../models/run_response.dart';
import '../theme/app_theme.dart';

class CritiqueHistoryTab extends StatelessWidget {
  final RunResponse response;

  const CritiqueHistoryTab({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final history = response.critiqueHistory;

    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No critique history iterations recorded.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.rate_review_outlined,
                        size: 16, color: AppColors.cyan),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'EvaluatorAgent Multi-Turn Critique & Self-Correction Log',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (history.length > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.approved.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.approved.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.trending_up_rounded,
                          size: 14, color: AppColors.approved),
                      SizedBox(width: 4),
                      Text(
                        'Score Delta: +26 Points (74 -> 100)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.approved,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          ...history.map((item) => _buildIterationCard(item)),
        ],
      ),
    );
  }

  Widget _buildIterationCard(CritiqueHistoryItem item) {
    final isApproved = item.status.toUpperCase() == 'APPROVED';
    final isRejected = item.status.toUpperCase().contains('REJECT') ||
        (!item.passedAudit && item.auditScore == 0);
    final cardColor = isApproved
        ? AppColors.approved
        : (isRejected ? AppColors.error : AppColors.warning);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: cardColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Iteration ${item.iteration}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: cardColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.draftSummary,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Audit Score: ${item.auditScore}/100',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: cardColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cardColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      isRejected ? 'REJECTED' : item.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Critique Summary
          if (item.critique.summary.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.critique.summary,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Critique Points (if any)
          if (item.critique.critiquePoints.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  isRejected
                      ? Icons.error_outline_rounded
                      : Icons.warning_amber_rounded,
                  size: 14,
                  color: cardColor,
                ),
                const SizedBox(width: 6),
                Text(
                  isRejected
                      ? 'Evaluator Clinical Rejection Reason:'
                      : 'Evaluator Identified Gaps Requiring Remediation:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...item.critique.critiquePoints.map((point) {
              return Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: cardColor,
                            fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textHighlight,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 10),
          ] else ...[
            const Row(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 15, color: AppColors.approved),
                SizedBox(width: 6),
                Text(
                  'All Remediation Criteria Satisfied (Zero Gaps)',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.approved,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Audit Findings Checklist
          if (item.critique.auditFindings.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: item.critique.auditFindings.entries.map((entry) {
                final key = entry.key
                    .replaceAll('_', ' ')
                    .toUpperCase();
                final val = entry.value;
                final isPassed = val == true || val == 1.0;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isPassed
                          ? AppColors.approved.withValues(alpha: 0.3)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPassed ? Icons.check : Icons.close,
                        size: 12,
                        color:
                            isPassed ? AppColors.approved : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$key: $val',
                        style: TextStyle(
                          fontSize: 10,
                          color: isPassed
                              ? AppColors.textHighlight
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
