import 'package:flutter/material.dart';
import '../services/document_parser_service.dart';
import '../theme/app_theme.dart';

class ClaimInputForm extends StatefulWidget {
  final TextEditingController claimIdController;
  final TextEditingController patientNameController;
  final TextEditingController payerNameController;
  final TextEditingController denialCodeController;
  final TextEditingController deniedCptController;
  final TextEditingController deniedAmountController;
  final TextEditingController denialReasonController;
  final TextEditingController clinicalNotesController;
  final bool isLoading;
  final int elapsedSeconds;
  final VoidCallback onRunPipeline;
  final VoidCallback onResetForm;
  final Future<ParsedDocument?> Function()? documentPicker;

  const ClaimInputForm({
    super.key,
    required this.claimIdController,
    required this.patientNameController,
    required this.payerNameController,
    required this.denialCodeController,
    required this.deniedCptController,
    required this.deniedAmountController,
    required this.denialReasonController,
    required this.clinicalNotesController,
    required this.isLoading,
    required this.elapsedSeconds,
    required this.onRunPipeline,
    required this.onResetForm,
    this.documentPicker,
  });

  @override
  State<ClaimInputForm> createState() => _ClaimInputFormState();
}

class _ClaimInputFormState extends State<ClaimInputForm> {
  bool _isParsingFile = false;
  String? _uploadedFileName;
  int? _uploadedFileSize;
  int? _uploadedPageCount;
  bool _isPdf = false;

  Future<void> _handlePickDocument() async {
    if (widget.isLoading || _isParsingFile) return;

    setState(() {
      _isParsingFile = true;
    });

    try {
      final picker = widget.documentPicker ?? DocumentParserService.pickAndParseDocument;
      final parsedDoc = await picker();
      if (!mounted) return;

      if (parsedDoc != null) {
        widget.clinicalNotesController.text = parsedDoc.text;
        setState(() {
          _uploadedFileName = parsedDoc.fileName;
          _uploadedFileSize = parsedDoc.fileSize;
          _uploadedPageCount = parsedDoc.pageCount;
          _isPdf = parsedDoc.isPdf;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          content: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Failed to parse document: $e',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isParsingFile = false;
        });
      }
    }
  }

  void _handleReset() {
    setState(() {
      _uploadedFileName = null;
      _uploadedFileSize = null;
      _uploadedPageCount = null;
    });
    widget.onResetForm();
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: AppColors.cyan,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Claim & Clinical Encounter Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: widget.isLoading ? null : _handleReset,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Reset', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Row 1: Claim ID & Patient Name
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildTextField(
                controller: widget.claimIdController,
                label: 'Claim ID',
                hint: 'e.g. CLM-90281-A',
                icon: Icons.numbers_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 6,
              child: _buildTextField(
                controller: widget.patientNameController,
                label: 'Patient Name',
                hint: 'e.g. Eleanor Vance',
                icon: Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Payer Name & Denial Code
        Row(
          children: [
            Expanded(
              flex: 7,
              child: _buildTextField(
                controller: widget.payerNameController,
                label: 'Payer / Health Plan',
                hint: 'e.g. Anthem Blue Cross Blue Shield',
                icon: Icons.corporate_fare_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: _buildTextField(
                controller: widget.denialCodeController,
                label: 'Denial Code',
                hint: 'CO-50 / CO-16 / CO-18',
                icon: Icons.rule_rounded,
                isHighlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 3: Denied CPT & Billed Amount
        Row(
          children: [
            Expanded(
              flex: 5,
              child: _buildTextField(
                controller: widget.deniedCptController,
                label: 'Denied / Billed CPT',
                hint: 'e.g. 71045',
                icon: Icons.medical_services_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 6,
              child: _buildTextField(
                controller: widget.deniedAmountController,
                label: 'Billed Charge Amount (\$)',
                hint: 'e.g. 345.00',
                icon: Icons.attach_money_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 4: Denial Reason
        _buildTextField(
          controller: widget.denialReasonController,
          label: 'Payer Denial Reason / EOB Text',
          hint: 'e.g. Service not medically necessary based on billed diagnosis M54.5',
          icon: Icons.info_outline_rounded,
        ),
        const SizedBox(height: 14),

        // Document Upload Zone: PDF / EHR File Selector
        _buildFileUploadZone(),
        const SizedBox(height: 14),

        // Row 5: Clinical Notes Header & Character Count
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Physician Encounter Note (EHR Progress Note)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.clinicalNotesController,
              builder: (context, value, _) {
                final length = value.text.length;
                return Text(
                  '$length chars',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontFamily: 'monospace',
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.clinicalNotesController,
          maxLines: 7,
          minLines: 5,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            height: 1.4,
            color: AppColors.textHighlight,
          ),
          decoration: InputDecoration(
            hintText:
                'Paste clinical progress note with symptoms, objective findings, assessment & plan, or use the PDF upload button above...',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Action Button: Run Multi-Agent Audit Pipeline
        _buildRunButton(),
      ],
    );
  }

  Widget _buildFileUploadZone() {
    final hasUploaded = _uploadedFileName != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasUploaded
              ? AppColors.approved.withValues(alpha: 0.5)
              : AppColors.cyan.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (hasUploaded ? AppColors.approved : AppColors.cyan)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  hasUploaded
                      ? (_isPdf ? Icons.picture_as_pdf_rounded : Icons.description_rounded)
                      : Icons.upload_file_rounded,
                  color: hasUploaded ? AppColors.approved : AppColors.cyan,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasUploaded
                          ? 'Uploaded Document Attached'
                          : 'Upload EHR / Denial PDF',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasUploaded
                          ? '${_uploadedFileName!} • ${_formatFileSize(_uploadedFileSize)}${_uploadedPageCount != null ? ' • ${_uploadedPageCount!} page(s)' : ''}'
                          : 'PDF or TXT encounter records auto-extract directly into encounter notes',
                      style: TextStyle(
                        fontSize: 11,
                        color: hasUploaded
                            ? AppColors.approved
                            : AppColors.textMuted,
                        fontFamily: hasUploaded ? 'monospace' : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.isLoading || _isParsingFile
                      ? null
                      : _handlePickDocument,
                  icon: _isParsingFile
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          hasUploaded
                              ? Icons.file_upload_outlined
                              : Icons.picture_as_pdf_rounded,
                          size: 16,
                        ),
                  label: Text(
                    _isParsingFile
                        ? 'Extracting Document Text...'
                        : (hasUploaded
                            ? 'Re-upload / Replace File'
                            : 'Upload EHR / Denial PDF'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasUploaded
                        ? AppColors.surfaceElevated
                        : AppColors.cyan.withValues(alpha: 0.2),
                    foregroundColor:
                        hasUploaded ? AppColors.textPrimary : AppColors.cyan,
                    side: BorderSide(
                      color: hasUploaded
                          ? AppColors.border
                          : AppColors.cyan.withValues(alpha: 0.8),
                      width: 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (hasUploaded) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Clear uploaded note',
                  onPressed: () {
                    setState(() {
                      _uploadedFileName = null;
                      _uploadedFileSize = null;
                      _uploadedPageCount = null;
                    });
                    widget.clinicalNotesController.clear();
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceElevated,
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isHighlight = false,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13,
            color: isHighlight ? AppColors.cyan : AppColors.textPrimary,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w400,
            fontFamily: isHighlight ? 'monospace' : null,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 16, color: AppColors.textMuted),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildRunButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: widget.isLoading
              ? [AppColors.surfaceElevated, AppColors.surfaceElevated]
              : [
                  AppColors.approved,
                  const Color(0xFF059669),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: widget.isLoading
            ? null
            : [
                BoxShadow(
                  color: AppColors.approved.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onRunPipeline,
          borderRadius: BorderRadius.circular(10),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: widget.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.cyan),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Synthesizing Reasoning Pipeline (${widget.elapsedSeconds}s)...',
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Run Multi-Agent Audit Pipeline',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
