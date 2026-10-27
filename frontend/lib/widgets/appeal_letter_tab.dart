import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/run_response.dart';
import '../theme/app_theme.dart';

class AppealLetterTab extends StatelessWidget {
  final RunResponse response;

  const AppealLetterTab({super.key, required this.response});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.approved, size: 18),
            SizedBox(width: 8),
            Text(
              'Statutory Appeal Letter copied to clipboard!',
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
    final isRejected = response.status.toUpperCase().contains('REJECT') ||
        (!response.auditScorecard.passed && response.auditScorecard.score == 0);

    if (isRejected) {
      final rejectionReason = response.auditScorecard.critiquePoints.isNotEmpty
          ? response.auditScorecard.critiquePoints.first
          : (response.critiqueHistory.isNotEmpty
              ? response.critiqueHistory.first.critique.summary
              : 'The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.');

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.block_rounded,
                          color: AppColors.error, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Statutory Appeal Package Ineligible',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No statutory appeal package was generated for this claim because the uploaded document failed clinical validation.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rejectionReason,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline_rounded,
                          color: AppColors.cyan, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Required Medical Documentation Criteria',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'To synthesize a legally binding ERISA / ACA statutory appeal, the clinical attachment must include at least 2 clinical indicators such as:\n'
                    '• Patient identity, attending physician, and examination findings\n'
                    '• Clinical assessment, diagnosis, or ICD-10 indication\n'
                    '• Documented symptoms, treatment plan, vitals, or Rx\n'
                    '• Procedure CPT coding documentation',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final appeal = response.appealPackage;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar: Copy button & summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appeal.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _copyToClipboard(context, appeal.appealLetter),
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Copy Appeal Letter', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan.withValues(alpha: 0.15),
                  foregroundColor: AppColors.cyan,
                  elevation: 0,
                  side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Statutory Citations Pills
          if (appeal.statutoryCitations.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: appeal.statutoryCitations.map((citation) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.indigo.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.indigo.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.gavel, size: 11, color: AppColors.indigo),
                      const SizedBox(width: 5),
                      Text(
                        citation,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7D2FE),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Formatted Letter Document Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: SelectableText(
              appeal.appealLetter,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.6,
                color: AppColors.textHighlight,
                letterSpacing: 0.1,
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Clinical Evidence & Coding Crosswalk Summary Card
          Container(
            padding: const EdgeInsets.all(14),
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
                    Icon(Icons.fact_check_outlined,
                        size: 16, color: AppColors.approved),
                    SizedBox(width: 8),
                    Text(
                      'Verified Clinical Evidence & Crosswalk Findings',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...appeal.clinicalEvidence.map((ev) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right,
                            size: 16, color: AppColors.approved),
                        const SizedBox(width: 4),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.textSecondary),
                              children: [
                                TextSpan(
                                  text: '${ev.source}: ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary),
                                ),
                                TextSpan(text: '"${ev.finding}" '),
                                TextSpan(
                                  text: '[ICD-10: ${ev.primaryIcd10}]',
                                  style: const TextStyle(
                                      color: AppColors.cyan,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
