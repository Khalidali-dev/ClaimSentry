import 'claim_request.dart';
import 'run_response.dart';

class PresetClaim {
  final String id;
  final String title;
  final String subtitle;
  final String denialCode;
  final String deniedCpt;
  final double deniedAmount;
  final String payerName;
  final String patientName;
  final String claimId;
  final String? patientDob;
  final String? memberId;
  final String denialReason;
  final String clinicalNotes;
  final Map<String, dynamic> sampleResponseJson;

  PresetClaim({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.denialCode,
    required this.deniedCpt,
    required this.deniedAmount,
    required this.payerName,
    required this.patientName,
    required this.claimId,
    this.patientDob,
    this.memberId,
    required this.denialReason,
    required this.clinicalNotes,
    required this.sampleResponseJson,
  });

  ClaimRequest toClaimRequest({String? customRequestId}) {
    return ClaimRequest(
      requestId: customRequestId ?? 'REQ-WEB-${id.toUpperCase()}',
      denialNotice: DenialNotice(
        claimId: claimId,
        patientName: patientName,
        patientDob: patientDob,
        memberId: memberId,
        payerName: payerName,
        deniedCpt: deniedCpt,
        deniedAmount: deniedAmount,
        denialCode: denialCode,
        denialReason: denialReason,
      ),
      clinicalNotes: clinicalNotes,
    );
  }

  RunResponse getSampleResponse() {
    return RunResponse.fromJson(sampleResponseJson);
  }
}
