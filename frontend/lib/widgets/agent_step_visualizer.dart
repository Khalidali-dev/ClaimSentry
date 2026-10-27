import 'package:flutter/material.dart';
import '../models/run_response.dart';
import '../theme/app_theme.dart';

class AgentStepVisualizer extends StatelessWidget {
  final bool isLoading;
  final int currentStepIndex; // 0: Planner, 1: Executor, 2: Evaluator, 3: Revision
  final RunResponse? runResponse;

  const AgentStepVisualizer({
    super.key,
    required this.isLoading,
    this.currentStepIndex = -1,
    this.runResponse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.account_tree_outlined,
                      color: AppColors.indigo,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Multi-Agent Reasoning Architecture (Iterative Loop)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (runResponse != null) ...[
                if (runResponse!.status.toUpperCase().contains('REJECT'))
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cancel_rounded,
                            size: 12, color: AppColors.error),
                        SizedBox(width: 4),
                        Text(
                          'Audit Rejected',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.approved.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${runResponse!.iterationsCount} Iterations Executed',
                      style: const TextStyle(
                        color: AppColors.approved,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 620;

              final steps = [
                _StepData(
                  stepNum: 1,
                  agentName: 'PlannerAgent',
                  role: 'Triage & Strategy',
                  model: 'meterless/auto',
                  description: 'Analyzes denial & queries Zetaris rules',
                ),
                _StepData(
                  stepNum: 2,
                  agentName: 'ExecutorAgent',
                  role: 'Draft Synthesis',
                  model: 'meterless/auto',
                  description: 'Extracts EHR proof & crafts statutory appeal',
                ),
                _StepData(
                  stepNum: 3,
                  agentName: 'EvaluatorAgent',
                  role: 'Audit & Critique',
                  model: 'meterless/deep',
                  description: 'Scores evidence & flags statutory gaps',
                ),
                _StepData(
                  stepNum: 4,
                  agentName: 'Revision Loop',
                  role: 'Self-Correction',
                  model: 'feedback-cycle',
                  description: 'Optimizes draft to 100/100 threshold',
                ),
              ];

              if (isNarrow) {
                return Column(
                  children: steps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildStepItem(step, index),
                    );
                  }).toList(),
                );
              }

              return Row(
                children: steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == steps.length - 1;

                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildStepItem(step, index)),
                        if (!isLast)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.borderLight,
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(_StepData step, int index) {
    bool isStepActive = false;
    bool isStepDone = false;

    final isRejected =
        runResponse?.status.toUpperCase().contains('REJECT') ?? false;

    if (isLoading) {
      if (currentStepIndex == index) {
        isStepActive = true;
      } else if (currentStepIndex > index) {
        isStepDone = true;
      }
    } else if (runResponse != null) {
      if (isRejected) {
        // Steps 1 & 3 executed (planner & evaluator rejection), step 4 skipped
        isStepDone = index < 3;
      } else {
        isStepDone = true;
      }
    }

    Color activeColor = AppColors.cyan;
    if (isRejected) {
      if (index == 2) {
        activeColor = AppColors.error;
      } else if (index == 1 || index == 3) {
        activeColor = AppColors.textMuted;
      }
    } else if (index == 2 && runResponse != null) {
      // Evaluator had critique
      activeColor = AppColors.warning;
    } else if (index == 3 && runResponse != null) {
      activeColor = AppColors.approved;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isStepActive
            ? AppColors.surfaceElevated
            : isStepDone
                ? AppColors.surface
                : AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isStepActive
              ? activeColor
              : isStepDone
                  ? activeColor.withValues(alpha: 0.4)
                  : AppColors.border,
          width: isStepActive ? 1.5 : 1,
        ),
        boxShadow: isStepActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.25),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${step.stepNum}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isStepActive || isStepDone
                      ? activeColor
                      : AppColors.textMuted,
                ),
              ),
              if (isStepActive)
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                  ),
                )
              else if (isStepDone)
                Icon(
                  (isRejected && index == 2)
                      ? Icons.cancel_rounded
                      : Icons.check_circle_rounded,
                  size: 13,
                  color: activeColor,
                )
              else
                const Icon(
                  Icons.circle_outlined,
                  size: 10,
                  color: AppColors.textMuted,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            step.agentName,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            step.role,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final int stepNum;
  final String agentName;
  final String role;
  final String model;
  final String description;

  _StepData({
    required this.stepNum,
    required this.agentName,
    required this.role,
    required this.model,
    required this.description,
  });
}
