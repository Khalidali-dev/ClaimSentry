import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:claim_sentry/data/presets_data.dart';
import 'package:claim_sentry/main.dart';
import 'package:claim_sentry/models/claim_request.dart';
import 'package:claim_sentry/models/run_response.dart';
import 'package:claim_sentry/services/api_service.dart';
import 'package:claim_sentry/services/document_parser_service.dart';

Uint8List createSamplePdfBytes(String text) {
  final document = PdfDocument();
  final page = document.pages.add();
  page.graphics.drawString(
    text,
    PdfStandardFont(PdfFontFamily.helvetica, 12),
    bounds: const Rect.fromLTWH(0, 0, 500, 700),
  );
  final List<int> bytes = document.saveSync();
  document.dispose();
  return Uint8List.fromList(bytes);
}

class FakeSuccessApiService extends ApiService {
  @override
  Future<ApiResult<RunResponse>> runPipeline(ClaimRequest request) async {
    return ApiResult.success(
      RunResponse.fromJson(samplePresets[0].sampleResponseJson),
    );
  }
}

void main() {
  testWidgets('ClaimSentry dashboard smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ClaimSentryApp());
    await tester.pumpAndSettle();

    // Verify header branding
    expect(find.text('ClaimSentry'), findsOneWidget);
    expect(find.text('Track 03: Reasoning Architecture'), findsOneWidget);

    // Verify presets are displayed
    expect(find.text('Preset 1: CO-50 Medical Necessity'), findsOneWidget);
    expect(find.text('Preset 2: CO-16 Missing Documentation'), findsOneWidget);
    expect(find.text('Preset 3: CO-18 Duplicate Claim'), findsOneWidget);

    // Verify default CPT code is 71045
    expect(find.text('71045'), findsOneWidget);

    // Verify Action button
    expect(find.text('Run Multi-Agent Audit Pipeline'), findsOneWidget);

    // Verify File Upload section
    expect(find.text('Upload EHR / Denial PDF'), findsWidgets);

    // Verify Agent Step Visualizer
    expect(find.text('Step 1'), findsOneWidget);
    expect(find.text('PlannerAgent'), findsOneWidget);
    expect(find.text('Step 2'), findsOneWidget);
    expect(find.text('ExecutorAgent'), findsOneWidget);
    expect(find.text('Step 3'), findsOneWidget);
    expect(find.text('EvaluatorAgent'), findsOneWidget);
    expect(find.text('Step 4'), findsOneWidget);
    expect(find.text('Revision Loop'), findsOneWidget);
  });

  testWidgets('Selecting Preset 2 updates form fields to CO-16 and CPT 99244',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ClaimSentryApp());
    await tester.pumpAndSettle();

    // Tap Preset 2
    final preset2Finder = find.text('Preset 2: CO-16 Missing Documentation');
    expect(preset2Finder, findsOneWidget);
    await tester.tap(preset2Finder);
    await tester.pumpAndSettle();

    // Verify fields updated
    expect(find.text('99244'), findsOneWidget);
    expect(find.text('CO-16'), findsNWidgets(2));
    expect(find.text('Arthur Pendelton'), findsOneWidget);
  });

  testWidgets('PDF upload populates clinical notes without showing toast',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const extractedSampleText =
        'Patient presents with acute onset retrosternal chest pain (R07.9) and dyspnea. CXR ordered.';
    final samplePdfBytes = createSamplePdfBytes(extractedSampleText);

    await tester.pumpWidget(
      ClaimSentryApp(
        documentPicker: () async {
          return DocumentParserService.parseBytes(
            fileName: 'eob_chest_pain_ehr.pdf',
            bytes: samplePdfBytes,
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Find and tap the upload button
    final uploadButton = find.widgetWithText(ElevatedButton, 'Upload EHR / Denial PDF');
    expect(uploadButton, findsOneWidget);
    await tester.ensureVisible(uploadButton);
    await tester.pumpAndSettle();
    await tester.tap(uploadButton);
    await tester.pumpAndSettle();

    // Verify toast/snackbar is NOT shown when PDF file is picked
    expect(
      find.text('PDF parsed successfully into clinical encounter notes'),
      findsNothing,
    );
    expect(find.byType(SnackBar), findsNothing);

    // Verify clinical notes text was populated
    expect(find.textContaining('retrosternal chest pain'), findsOneWidget);

    // Verify file banner details
    expect(find.text('Uploaded Document Attached'), findsOneWidget);
    expect(find.textContaining('eob_chest_pain_ehr.pdf'), findsOneWidget);
  });

  test('DocumentParserService extracts text from both TXT and PDF bytes', () {
    // 1. Text file test
    final txtBytes = Uint8List.fromList(
      utf8.encode('STAT Consultation requested for acute postoperative pain.'),
    );
    final txtResult = DocumentParserService.parseBytes(
      fileName: 'physician_note.txt',
      bytes: txtBytes,
    );
    expect(txtResult.isPdf, isFalse);
    expect(txtResult.text, contains('STAT Consultation requested'));

    // 2. PDF file test
    final pdfBytes = createSamplePdfBytes(
      'Encounter Date: 2026-03-12. Bilateral knee injection performed under ultrasound guidance.',
    );
    final pdfResult = DocumentParserService.parseBytes(
      fileName: 'knee_injection_ehr.pdf',
      bytes: pdfBytes,
    );
    expect(pdfResult.isPdf, isTrue);
    expect(pdfResult.pageCount, equals(1));
    expect(pdfResult.text, contains('Bilateral knee injection'));
  });

  testWidgets(
      'Running Pipeline renders Scorecard and all 3 Tabbed viewers',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ClaimSentryApp(
        apiService: FakeSuccessApiService(),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to and tap Run Multi-Agent Audit Pipeline
    final runButton = find.text('Run Multi-Agent Audit Pipeline');
    expect(runButton, findsOneWidget);
    await tester.ensureVisible(runButton);
    await tester.pumpAndSettle();
    await tester.tap(runButton);
    await tester.pumpAndSettle();

    // Verify Scorecard metric card
    expect(find.text('100 / 100'), findsOneWidget);
    expect(find.text('APPROVED'), findsWidgets);

    // Verify Tab 1: Formatted Statutory Appeal Letter
    expect(find.text('Tab 1: Statutory Appeal Letter'), findsOneWidget);
    expect(find.text('Copy Appeal Letter'), findsOneWidget);

    // Switch to Tab 2: Evaluator Critique History
    final tab2 = find.text('Tab 2: Evaluator Critique History');
    await tester.tap(tab2);
    await tester.pumpAndSettle();

    expect(find.text('Score Delta: +26 Points (74 -> 100)'), findsOneWidget);
    expect(find.text('Iteration 1'), findsOneWidget);
    expect(find.text('Iteration 2'), findsOneWidget);

    // Switch to Tab 3: H-MEM & Raw Traces
    final tab3 = find.text('Tab 3: H-MEM & Raw Traces');
    await tester.tap(tab3);
    await tester.pumpAndSettle();

    expect(find.text('Copy Raw JSON'), findsOneWidget);
    expect(find.text('Layer 1: Ephemeral Claim Facts & Entities'), findsOneWidget);
    expect(find.text('Layer 2: Zetaris Enterprise Policy Precedents'), findsOneWidget);
    expect(find.text('Layer 3: Epistemic Critique & Reflection Loop'), findsOneWidget);
  });
}
