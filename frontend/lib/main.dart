import 'dart:async';
import 'package:flutter/material.dart';
import 'data/presets_data.dart';
import 'models/claim_request.dart';
import 'models/preset_claim.dart';
import 'models/run_response.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'widgets/agent_step_visualizer.dart';
import 'widgets/appeal_letter_tab.dart';
import 'widgets/app_header.dart';
import 'widgets/audit_scorecard_card.dart';
import 'widgets/claim_input_form.dart';
import 'widgets/critique_history_tab.dart';
import 'widgets/empty_results_view.dart';
import 'widgets/hmem_trace_tab.dart';
import 'widgets/preset_selector.dart';
import 'widgets/status_bar.dart';
import 'config/app_config.dart';
import 'services/document_parser_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClaimSentryApp());
}

class ClaimSentryApp extends StatelessWidget {
  final Future<ParsedDocument?> Function()? documentPicker;
  final ApiService? apiService;
  const ClaimSentryApp({super.key, this.documentPicker, this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClaimSentry | Track 03 Claim Denial Auditor & Statutory Appeal Synthesizer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: DashboardScreen(
        documentPicker: documentPicker,
        apiService: apiService,
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final Future<ParsedDocument?> Function()? documentPicker;
  final ApiService? apiService;
  const DashboardScreen({super.key, this.documentPicker, this.apiService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // Service
  late final ApiService _apiService;

  // Controllers
  final _claimIdController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _payerNameController = TextEditingController();
  final _denialCodeController = TextEditingController();
  final _deniedCptController = TextEditingController();
  final _deniedAmountController = TextEditingController();
  final _denialReasonController = TextEditingController();
  final _clinicalNotesController = TextEditingController();

  // Tab controller for Right Column tabs
  late TabController _tabController;

  // State
  PresetClaim? _selectedPreset;
  bool _isLoading = false;
  int _loadingStepIndex = 0;
  int _elapsedSeconds = 0;
  Timer? _stopwatchTimer;
  Timer? _stepAnimationTimer;

  bool _isBackendHealthy = true;
  RunResponse? _runResponse;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _tabController = TabController(length: 3, vsync: this);

    // Auto-select Preset 1 by default
    _applyPreset(samplePresets.first);

    // Initial health check
    _checkHealth();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stopwatchTimer?.cancel();
    _stepAnimationTimer?.cancel();
    _claimIdController.dispose();
    _patientNameController.dispose();
    _payerNameController.dispose();
    _denialCodeController.dispose();
    _deniedCptController.dispose();
    _deniedAmountController.dispose();
    _denialReasonController.dispose();
    _clinicalNotesController.dispose();
    super.dispose();
  }

  void _applyPreset(PresetClaim preset) {
    setState(() {
      _selectedPreset = preset;
      _claimIdController.text = preset.claimId;
      _patientNameController.text = preset.patientName;
      _payerNameController.text = preset.payerName;
      _denialCodeController.text = preset.denialCode;
      _deniedCptController.text = preset.deniedCpt;
      _deniedAmountController.text = preset.deniedAmount.toStringAsFixed(2);
      _denialReasonController.text = preset.denialReason;
      _clinicalNotesController.text = preset.clinicalNotes;
    });
  }

  Future<void> _checkHealth() async {
    final result = await _apiService.checkHealth();
    if (mounted) {
      setState(() {
        _isBackendHealthy = result.isSuccess;
      });
    }
  }

  void _startTimers() {
    _elapsedSeconds = 0;
    _loadingStepIndex = 0;

    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });

    _stepAnimationTimer?.cancel();
    _stepAnimationTimer =
        Timer.periodic(const Duration(milliseconds: 1400), (timer) {
      if (mounted && _isLoading) {
        setState(() {
          if (_loadingStepIndex < 3) {
            _loadingStepIndex++;
          }
        });
      }
    });
  }

  void _stopTimers() {
    _stopwatchTimer?.cancel();
    _stepAnimationTimer?.cancel();
  }

  Future<void> _handleRunPipeline() async {
    // Validate inputs
    final cpt = _deniedCptController.text.trim();
    final denialCode = _denialCodeController.text.trim();

    if (cpt.isEmpty || denialCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least a Denial Code and CPT Code.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _startTimers();

    final amount = double.tryParse(_deniedAmountController.text.trim()) ?? 0.0;
    final claimReq = ClaimRequest(
      requestId: 'REQ-WEB-${DateTime.now().millisecondsSinceEpoch % 100000}',
      denialNotice: DenialNotice(
        claimId: _claimIdController.text.trim().isNotEmpty
            ? _claimIdController.text.trim()
            : 'CLM-${DateTime.now().millisecondsSinceEpoch % 10000}',
        patientName: _patientNameController.text.trim(),
        payerName: _payerNameController.text.trim(),
        denialCode: denialCode,
        deniedCpt: cpt,
        deniedAmount: amount,
        denialReason: _denialReasonController.text.trim(),
      ),
      clinicalNotes: _clinicalNotesController.text.trim(),
    );

    // Live mode: call API endpoint POST ${AppConfig.runEndpoint}
    final result = await _apiService.runPipeline(claimReq);

    _stopTimers();
    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      setState(() {
        _isLoading = false;
        _runResponse = result.data;
        _errorMessage = null;
        _isBackendHealthy = true;
      });
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage;
        if (result.isConnectionError) {
          _isBackendHealthy = false;
        }
      });
    }
  }

  void _handleResetForm() {
    if (_selectedPreset != null) {
      _applyPreset(_selectedPreset!);
    } else {
      _applyPreset(samplePresets.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header with branding & Track 03 badge
            AppHeader(
              isBackendHealthy: _isBackendHealthy,
              onRefreshHealth: _checkHealth,
              apiEndpoint: 'POST ${AppConfig.runEndpoint}',
            ),

            // 2. Status Bar with Daemon Port 8088 & Zetaris Layer
            StatusBar(
              isBackendHealthy: _isBackendHealthy,
              meterlessStatus: _isBackendHealthy
                  ? 'Port 8088 (Live Inference Online)'
                  : 'Port 8088 (Reconnecting...)',
              zetarisStatus: 'Port 8888 (Live Lakehouse Connected)',
              apiEndpoint: 'POST ${AppConfig.runEndpoint}',
            ),

            // 3. Error Banner (if any)
            if (_errorMessage != null) _buildErrorBanner(),

            // 4. Two-Column Dashboard Layout
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1050;

                  if (!isWide) {
                    // Mobile / Tablet stacked view
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildLeftColumn(),
                          const SizedBox(height: 24),
                          _buildRightColumn(),
                        ],
                      ),
                    );
                  }

                  // Wide desktop side-by-side two columns
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Input Form & Presets
                      SizedBox(
                        width: 480,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildLeftColumn(),
                        ),
                      ),
                      const VerticalDivider(width: 1),

                      // Right Column: Interactive Agent Reasoning & Results
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: _buildRightColumn(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PresetSelector(
          presets: samplePresets,
          selectedPreset: _selectedPreset,
          onSelectPreset: (preset) {
            _applyPreset(preset);
          },
        ),
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 16),
        ClaimInputForm(
          claimIdController: _claimIdController,
          patientNameController: _patientNameController,
          payerNameController: _payerNameController,
          denialCodeController: _denialCodeController,
          deniedCptController: _deniedCptController,
          deniedAmountController: _deniedAmountController,
          denialReasonController: _denialReasonController,
          clinicalNotesController: _clinicalNotesController,
          isLoading: _isLoading,
          elapsedSeconds: _elapsedSeconds,
          onRunPipeline: _handleRunPipeline,
          onResetForm: _handleResetForm,
          documentPicker: widget.documentPicker,
        ),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Agent Step Visualizer
        AgentStepVisualizer(
          isLoading: _isLoading,
          currentStepIndex: _loadingStepIndex,
          runResponse: _runResponse,
        ),
        const SizedBox(height: 14),

        // 2. Scorecard Metric Card (if results available)
        if (_runResponse != null) ...[
          AuditScorecardCard(response: _runResponse!),
          const SizedBox(height: 14),
        ],

        // 3. Tabbed Viewer or Empty View
        Expanded(
          child: _runResponse == null && !_isLoading
              ? EmptyResultsView(
                  onQuickRun: () {
                    _applyPreset(samplePresets.first);
                    _handleRunPipeline();
                  },
                )
              : _buildTabbedViewer(),
        ),
      ],
    );
  }

  Widget _buildTabbedViewer() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.cyan,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.cyan,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.description_outlined, size: 16),
                  text: 'Tab 1: Statutory Appeal Letter',
                ),
                Tab(
                  icon: Icon(Icons.rate_review_outlined, size: 16),
                  text: 'Tab 2: Evaluator Critique History',
                ),
                Tab(
                  icon: Icon(Icons.schema_outlined, size: 16),
                  text: 'Tab 3: H-MEM & Raw Traces',
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      AppealLetterTab(response: _runResponse!),
                      CritiqueHistoryTab(response: _runResponse!),
                      HMemTraceTab(response: _runResponse!),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyan),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Autonomous Multi-Agent Reasoning in Progress...',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PlannerAgent -> ExecutorAgent -> EvaluatorAgent -> Revision Loop\nElapsed: ${_elapsedSeconds}s',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pipeline Connection Notice',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textHighlight,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
              _handleRunPipeline();
            },
            icon: const Icon(Icons.refresh, size: 13),
            label: const Text('Retry', style: TextStyle(fontSize: 11)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceElevated,
              foregroundColor: AppColors.cyan,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }
}
