class RunResponse {
  final String requestId;
  final String status;
  final int iterationsCount;
  final RemediationPlan remediationPlan;
  final AuditScorecard auditScorecard;
  final List<CritiqueHistoryItem> critiqueHistory;
  final AppealPackage appealPackage;
  final HMemSummary hMemSummary;
  final List<TraceSummaryItem> traceSummary;

  RunResponse({
    required this.requestId,
    required this.status,
    required this.iterationsCount,
    required this.remediationPlan,
    required this.auditScorecard,
    required this.critiqueHistory,
    required this.appealPackage,
    required this.hMemSummary,
    required this.traceSummary,
  });

  factory RunResponse.fromJson(Map<String, dynamic> json) {
    return RunResponse(
      requestId: json['request_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      iterationsCount: (json['iterations_count'] as num?)?.toInt() ?? 1,
      remediationPlan: RemediationPlan.fromJson(
        json['remediation_plan'] as Map<String, dynamic>? ?? {},
      ),
      auditScorecard: AuditScorecard.fromJson(
        json['audit_scorecard'] as Map<String, dynamic>? ?? {},
      ),
      critiqueHistory: (json['critique_history'] as List<dynamic>?)
              ?.map((e) =>
                  CritiqueHistoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      appealPackage: AppealPackage.fromJson(
        json['appeal_package'] as Map<String, dynamic>? ?? {},
      ),
      hMemSummary: HMemSummary.fromJson(
        json['h_mem_summary'] as Map<String, dynamic>? ?? {},
      ),
      traceSummary: (json['trace_summary'] as List<dynamic>?)
              ?.map((e) => TraceSummaryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'status': status,
      'iterations_count': iterationsCount,
      'remediation_plan': remediationPlan.toJson(),
      'audit_scorecard': auditScorecard.toJson(),
      'critique_history': critiqueHistory.map((e) => e.toJson()).toList(),
      'appeal_package': appealPackage.toJson(),
      'h_mem_summary': hMemSummary.toJson(),
      'trace_summary': traceSummary.map((e) => e.toJson()).toList(),
    };
  }
}

class RemediationPlan {
  final String triageSummary;
  final String rootCauseAnalysis;
  final List<String> requiredEvidenceCriteria;
  final String recommendedIcd10;
  final List<String> statutoryCitations;
  final int matchedGuidelinesCount;
  final String targetIcd10;

  RemediationPlan({
    required this.triageSummary,
    required this.rootCauseAnalysis,
    required this.requiredEvidenceCriteria,
    required this.recommendedIcd10,
    required this.statutoryCitations,
    required this.matchedGuidelinesCount,
    required this.targetIcd10,
  });

  factory RemediationPlan.fromJson(Map<String, dynamic> json) {
    return RemediationPlan(
      triageSummary: json['triage_summary']?.toString() ?? '',
      rootCauseAnalysis: json['root_cause_analysis']?.toString() ?? '',
      requiredEvidenceCriteria:
          (json['required_evidence_criteria'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
      recommendedIcd10: json['recommended_icd10']?.toString() ?? '',
      statutoryCitations: (json['statutory_citations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      matchedGuidelinesCount:
          (json['matched_guidelines_count'] as num?)?.toInt() ?? 0,
      targetIcd10: json['target_icd10']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'triage_summary': triageSummary,
      'root_cause_analysis': rootCauseAnalysis,
      'required_evidence_criteria': requiredEvidenceCriteria,
      'recommended_icd10': recommendedIcd10,
      'statutory_citations': statutoryCitations,
      'matched_guidelines_count': matchedGuidelinesCount,
      'target_icd10': targetIcd10,
    };
  }
}

class AuditScorecard {
  final int score;
  final bool passed;
  final String status;
  final List<String> critiquePoints;

  AuditScorecard({
    required this.score,
    required this.passed,
    required this.status,
    required this.critiquePoints,
  });

  factory AuditScorecard.fromJson(Map<String, dynamic> json) {
    return AuditScorecard(
      score: (json['score'] as num?)?.toInt() ?? 0,
      passed: json['passed'] == true,
      status: json['status']?.toString() ?? 'PENDING',
      critiquePoints: (json['critique_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'passed': passed,
      'status': status,
      'critique_points': critiquePoints,
    };
  }
}

class CritiqueHistoryItem {
  final int iteration;
  final String timestamp;
  final String draftSummary;
  final DraftPackage draftPackage;
  final CritiqueDetail critique;
  final String status;
  final bool passedAudit;
  final int auditScore;

  CritiqueHistoryItem({
    required this.iteration,
    required this.timestamp,
    required this.draftSummary,
    required this.draftPackage,
    required this.critique,
    required this.status,
    required this.passedAudit,
    required this.auditScore,
  });

  factory CritiqueHistoryItem.fromJson(Map<String, dynamic> json) {
    return CritiqueHistoryItem(
      iteration: (json['iteration'] as num?)?.toInt() ?? 1,
      timestamp: json['timestamp']?.toString() ?? '',
      draftSummary: json['draft_summary']?.toString() ?? '',
      draftPackage: DraftPackage.fromJson(
        json['draft_package'] as Map<String, dynamic>? ?? {},
      ),
      critique: CritiqueDetail.fromJson(
        json['critique'] as Map<String, dynamic>? ?? {},
      ),
      status: json['status']?.toString() ?? '',
      passedAudit: json['passed_audit'] == true,
      auditScore: (json['audit_score'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iteration': iteration,
      'timestamp': timestamp,
      'draft_summary': draftSummary,
      'draft_package': draftPackage.toJson(),
      'critique': critique.toJson(),
      'status': status,
      'passed_audit': passedAudit,
      'audit_score': auditScore,
    };
  }
}

class DraftPackage {
  final String summary;
  final String appealLetter;
  final List<String> statutoryCitations;
  final List<ClinicalEvidence> clinicalEvidence;
  final CodingCrosswalk codingCrosswalk;

  DraftPackage({
    required this.summary,
    required this.appealLetter,
    required this.statutoryCitations,
    required this.clinicalEvidence,
    required this.codingCrosswalk,
  });

  factory DraftPackage.fromJson(Map<String, dynamic> json) {
    return DraftPackage(
      summary: json['summary']?.toString() ?? '',
      appealLetter: json['appeal_letter']?.toString() ?? '',
      statutoryCitations: (json['statutory_citations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      clinicalEvidence: (json['clinical_evidence'] as List<dynamic>?)
              ?.map((e) =>
                  ClinicalEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      codingCrosswalk: CodingCrosswalk.fromJson(
        json['coding_crosswalk'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'appeal_letter': appealLetter,
      'statutory_citations': statutoryCitations,
      'clinical_evidence': clinicalEvidence.map((e) => e.toJson()).toList(),
      'coding_crosswalk': codingCrosswalk.toJson(),
    };
  }
}

class CritiqueDetail {
  final bool passed;
  final int score;
  final String status;
  final String summary;
  final List<String> critiquePoints;
  final Map<String, dynamic> auditFindings;

  CritiqueDetail({
    required this.passed,
    required this.score,
    required this.status,
    required this.summary,
    required this.critiquePoints,
    required this.auditFindings,
  });

  factory CritiqueDetail.fromJson(Map<String, dynamic> json) {
    return CritiqueDetail(
      passed: json['passed'] == true,
      score: (json['score'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      critiquePoints: (json['critique_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      auditFindings: json['audit_findings'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passed': passed,
      'score': score,
      'status': status,
      'summary': summary,
      'critique_points': critiquePoints,
      'audit_findings': auditFindings,
    };
  }
}

class AppealPackage {
  final String summary;
  final String appealLetter;
  final List<String> statutoryCitations;
  final List<ClinicalEvidence> clinicalEvidence;
  final CodingCrosswalk codingCrosswalk;

  AppealPackage({
    required this.summary,
    required this.appealLetter,
    required this.statutoryCitations,
    required this.clinicalEvidence,
    required this.codingCrosswalk,
  });

  factory AppealPackage.fromJson(Map<String, dynamic> json) {
    return AppealPackage(
      summary: json['summary']?.toString() ?? '',
      appealLetter: json['appeal_letter']?.toString() ?? '',
      statutoryCitations: (json['statutory_citations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      clinicalEvidence: (json['clinical_evidence'] as List<dynamic>?)
              ?.map((e) =>
                  ClinicalEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      codingCrosswalk: CodingCrosswalk.fromJson(
        json['coding_crosswalk'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'appeal_letter': appealLetter,
      'statutory_citations': statutoryCitations,
      'clinical_evidence': clinicalEvidence.map((e) => e.toJson()).toList(),
      'coding_crosswalk': codingCrosswalk.toJson(),
    };
  }
}

class ClinicalEvidence {
  final String source;
  final String finding;
  final String primaryIcd10;

  ClinicalEvidence({
    required this.source,
    required this.finding,
    required this.primaryIcd10,
  });

  factory ClinicalEvidence.fromJson(Map<String, dynamic> json) {
    return ClinicalEvidence(
      source: json['source']?.toString() ?? '',
      finding: json['finding']?.toString() ?? '',
      primaryIcd10: json['primary_icd10']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'finding': finding,
      'primary_icd10': primaryIcd10,
    };
  }
}

class CodingCrosswalk {
  final String cptCode;
  final String billedIcd10;
  final String correctedIcd10;
  final String? modifierApplied;

  CodingCrosswalk({
    required this.cptCode,
    required this.billedIcd10,
    required this.correctedIcd10,
    this.modifierApplied,
  });

  factory CodingCrosswalk.fromJson(Map<String, dynamic> json) {
    return CodingCrosswalk(
      cptCode: json['cpt_code']?.toString() ?? '',
      billedIcd10: json['billed_icd10']?.toString() ?? '',
      correctedIcd10: json['corrected_icd10']?.toString() ?? '',
      modifierApplied: json['modifier_applied']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpt_code': cptCode,
      'billed_icd10': billedIcd10,
      'corrected_icd10': correctedIcd10,
      'modifier_applied': modifierApplied,
    };
  }
}

class HMemSummary {
  final String requestId;
  final String createdAt;
  final String claimId;
  final String denialCode;
  final int matchedPolicyCount;
  final int iterationCount;
  final int latestAuditScore;
  final String finalStatus;

  HMemSummary({
    required this.requestId,
    required this.createdAt,
    required this.claimId,
    required this.denialCode,
    required this.matchedPolicyCount,
    required this.iterationCount,
    required this.latestAuditScore,
    required this.finalStatus,
  });

  factory HMemSummary.fromJson(Map<String, dynamic> json) {
    return HMemSummary(
      requestId: json['request_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      claimId: json['claim_id']?.toString() ?? '',
      denialCode: json['denial_code']?.toString() ?? '',
      matchedPolicyCount: (json['matched_policy_count'] as num?)?.toInt() ?? 0,
      iterationCount: (json['iteration_count'] as num?)?.toInt() ?? 0,
      latestAuditScore: (json['latest_audit_score'] as num?)?.toInt() ?? 0,
      finalStatus: json['final_status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': requestId,
      'created_at': createdAt,
      'claim_id': claimId,
      'denial_code': denialCode,
      'matched_policy_count': matchedPolicyCount,
      'iteration_count': iterationCount,
      'latest_audit_score': latestAuditScore,
      'final_status': finalStatus,
    };
  }
}

class TraceSummaryItem {
  final String agent;
  final String action;
  final String status;
  final String model;

  TraceSummaryItem({
    required this.agent,
    required this.action,
    required this.status,
    required this.model,
  });

  factory TraceSummaryItem.fromJson(Map<String, dynamic> json) {
    return TraceSummaryItem(
      agent: json['agent']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent': agent,
      'action': action,
      'status': status,
      'model': model,
    };
  }
}
