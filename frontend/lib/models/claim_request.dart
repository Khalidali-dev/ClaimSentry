class DenialNotice {
  final String claimId;
  final String? patientName;
  final String? patientDob;
  final String? memberId;
  final String? payerName;
  final String? payerId;
  final String? dateOfService;
  final String deniedCpt;
  final String? billedCptDescription;
  final String? billedIcd10;
  final String? billedIcd10Description;
  final double deniedAmount;
  final String denialCode;
  final String? denialReason;
  final int timelyFilingDeadlineDays;

  DenialNotice({
    required this.claimId,
    this.patientName,
    this.patientDob,
    this.memberId,
    this.payerName,
    this.payerId,
    this.dateOfService,
    required this.deniedCpt,
    this.billedCptDescription,
    this.billedIcd10,
    this.billedIcd10Description,
    required this.deniedAmount,
    required this.denialCode,
    this.denialReason,
    this.timelyFilingDeadlineDays = 180,
  });

  Map<String, dynamic> toJson() {
    return {
      'claim_id': claimId,
      if (patientName != null) 'patient_name': patientName,
      if (patientDob != null) 'patient_dob': patientDob,
      if (memberId != null) 'member_id': memberId,
      if (payerName != null) 'payer_name': payerName,
      if (payerId != null) 'payer_id': payerId,
      if (dateOfService != null) 'date_of_service': dateOfService,
      // Supply both for full API contract and backend compatibility
      'denied_cpt': deniedCpt,
      'billed_cpt': deniedCpt,
      if (billedCptDescription != null)
        'billed_cpt_description': billedCptDescription,
      if (billedIcd10 != null) 'billed_icd10': billedIcd10,
      if (billedIcd10Description != null)
        'billed_icd10_description': billedIcd10Description,
      'denied_amount': deniedAmount,
      'billed_amount': deniedAmount,
      'denial_code': denialCode,
      if (denialReason != null) 'denial_reason': denialReason,
      'timely_filing_deadline_days': timelyFilingDeadlineDays,
    };
  }

  factory DenialNotice.fromJson(Map<String, dynamic> json) {
    return DenialNotice(
      claimId: json['claim_id']?.toString() ?? '',
      patientName: json['patient_name']?.toString(),
      patientDob: json['patient_dob']?.toString(),
      memberId: json['member_id']?.toString(),
      payerName: json['payer_name']?.toString(),
      payerId: json['payer_id']?.toString(),
      dateOfService: json['date_of_service']?.toString(),
      deniedCpt: (json['denied_cpt'] ?? json['billed_cpt'] ?? '').toString(),
      billedCptDescription: json['billed_cpt_description']?.toString(),
      billedIcd10: json['billed_icd10']?.toString(),
      billedIcd10Description: json['billed_icd10_description']?.toString(),
      deniedAmount: (json['denied_amount'] as num?)?.toDouble() ??
          (json['billed_amount'] as num?)?.toDouble() ??
          0.0,
      denialCode: json['denial_code']?.toString() ?? '',
      denialReason: json['denial_reason']?.toString(),
      timelyFilingDeadlineDays:
          (json['timely_filing_deadline_days'] as num?)?.toInt() ?? 180,
    );
  }
}

class ClaimRequest {
  final String requestId;
  final DenialNotice denialNotice;
  final String clinicalNotes;

  ClaimRequest({
    required this.requestId,
    required this.denialNotice,
    required this.clinicalNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'denial_notice': denialNotice.toJson(),
      'clinical_notes': clinicalNotes,
    };
  }

  factory ClaimRequest.fromJson(Map<String, dynamic> json) {
    return ClaimRequest(
      requestId: json['request_id']?.toString() ?? 'REQ-WEB-001',
      denialNotice: DenialNotice.fromJson(
        json['denial_notice'] as Map<String, dynamic>? ?? {},
      ),
      clinicalNotes: json['clinical_notes']?.toString() ?? '',
    );
  }
}
