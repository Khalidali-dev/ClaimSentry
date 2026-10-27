import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyResultsView extends StatelessWidget {
  final VoidCallback onQuickRun;

  const EmptyResultsView({super.key, required this.onQuickRun});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.indigo.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.indigo.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.psychology_outlined,
              size: 32,
              color: AppColors.indigo,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Ready to Audit & Synthesize Statutory Appeal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select one of the 3 pre-loaded claim presets or input custom claim notice & EHR encounter notes. Click "Run Multi-Agent Audit Pipeline" to initiate autonomous reasoning, statutory citation extraction, and self-correcting appeal generation.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildFeaturePoints(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onQuickRun,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text(
              'Run Sample Audit (CO-50 Medical Necessity)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
              foregroundColor: AppColors.cyan,
              elevation: 0,
              side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildFeaturePoints() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          _FeatureRow(
            icon: Icons.hub_outlined,
            title: 'Zetaris Federated Data Layer',
            desc: 'Queries live insurance billing policies, NCCI edits & ERISA statutory precedents.',
          ),
          SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.memory,
            title: 'Meterless Daemon & H-MEM',
            desc: 'Multi-layer memory engine retains facts, precedents, and reflection states.',
          ),
          SizedBox(height: 10),
          _FeatureRow(
            icon: Icons.loop_rounded,
            title: 'Self-Correcting Critique Loop',
            desc: 'EvaluatorAgent critiques drafts until 100/100 statutory compliance is certified.',
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.cyan),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
