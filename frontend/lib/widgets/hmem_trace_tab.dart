import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/run_response.dart';
import '../theme/app_theme.dart';

class HMemTraceTab extends StatelessWidget {
  final RunResponse response;

  const HMemTraceTab({super.key, required this.response});

  void _copyJson(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final formatted = encoder.convert(response.toJson());
    Clipboard.setData(ClipboardData(text: formatted));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.approved, size: 18),
            SizedBox(width: 8),
            Text(
              'Complete JSON payload & raw traces copied!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hMem = response.hMemSummary;
    final traces = response.traceSummary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Copy JSON action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.developer_board_rounded,
                        size: 16, color: AppColors.cyan),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'H-MEM Working Memory & JSONL Raw Execution Traces',
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
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _copyJson(context),
                icon: const Icon(Icons.code_rounded, size: 14),
                label: const Text('Copy Raw JSON', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigo.withValues(alpha: 0.15),
                  foregroundColor: AppColors.indigo,
                  elevation: 0,
                  side: BorderSide(color: AppColors.indigo.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // H-MEM 3-Layer Structure Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.layers_outlined,
                        size: 16, color: AppColors.indigo),
                    SizedBox(width: 8),
                    Text(
                      'H-MEM Hierarchical Working Memory State',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMemoryLayer(
                  layerNum: 1,
                  title: 'Layer 1: Ephemeral Claim Facts & Entities',
                  details:
                      'Request ID: ${hMem.requestId} | Claim ID: ${hMem.claimId} | Denial Code: ${hMem.denialCode}',
                  color: AppColors.cyan,
                ),
                const SizedBox(height: 8),
                _buildMemoryLayer(
                  layerNum: 2,
                  title: 'Layer 2: Zetaris Enterprise Policy Precedents',
                  details:
                      'Matched Rules: ${hMem.matchedPolicyCount} | Target Crosswalk: ${response.remediationPlan.targetIcd10} | Statutes: ${response.remediationPlan.statutoryCitations.length}',
                  color: AppColors.indigo,
                ),
                const SizedBox(height: 8),
                _buildMemoryLayer(
                  layerNum: 3,
                  title: 'Layer 3: Epistemic Critique & Reflection Loop',
                  details:
                      'Completed Iterations: ${hMem.iterationCount} | Final Score: ${hMem.latestAuditScore}/100 | Status: ${hMem.finalStatus}',
                  color: AppColors.approved,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // JSONL Trace Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'JSONL Event Execution Trace (${traces.length} steps)',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'OpenTelemetry / JSONL Compatible',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: traces.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final trace = traces[index];
                return _buildTraceTile(trace, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryLayer({
    required int layerNum,
    required String title,
    required String details,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              details,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: AppColors.textHighlight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraceTile(TraceSummaryItem trace, int stepNum) {
    Color agentColor;
    if (trace.agent.contains('Planner')) {
      agentColor = AppColors.cyan;
    } else if (trace.agent.contains('Executor')) {
      agentColor = AppColors.indigo;
    } else if (trace.agent.contains('Evaluator')) {
      agentColor = AppColors.purple;
    } else if (trace.agent.contains('Zetaris')) {
      agentColor = AppColors.warning;
    } else {
      agentColor = AppColors.textSecondary;
    }

    final isSuccess = trace.status == 'SUCCESS' || trace.status == 'APPROVED';
    final isCritique = trace.status.contains('CRITIQUE');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '#${stepNum.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: agentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: agentColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              trace.agent,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: agentColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trace.action,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'model: ${trace.model}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: isSuccess
                  ? AppColors.approved.withValues(alpha: 0.15)
                  : isCritique
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trace.status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSuccess
                    ? AppColors.approved
                    : isCritique
                        ? AppColors.warning
                        : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
