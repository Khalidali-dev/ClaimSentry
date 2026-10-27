import '../models/preset_claim.dart';

final List<PresetClaim> samplePresets = [
  // Preset 1: CO-50 Medical Necessity (Chest X-Ray 71045)
  PresetClaim(
    id: 'preset_1',
    title: 'Preset 1: CO-50 Medical Necessity',
    subtitle: 'Chest X-Ray (CPT 71045) | Eleanor Vance',
    denialCode: 'CO-50',
    deniedCpt: '71045',
    deniedAmount: 345.00,
    payerName: 'Anthem Blue Cross Blue Shield',
    patientName: 'Eleanor Vance',
    claimId: 'CLM-90281-A',
    patientDob: '1968-04-12',
    memberId: 'ANT-8829104',
    denialReason:
        'These are non-covered services because this is not deemed a "medical necessity" by the payer based on billed diagnosis M54.5.',
    clinicalNotes:
        'PATIENT ENCOUNTER NOTE\nPatient: Eleanor Vance | DOB: 04/12/1968 | DOS: 02/14/2026\nAttending Physician: Dr. Marcus Reed, MD (Internal Medicine, NPI: 1982736450)\nFacility: St. Jude Metropolitan Medical Pavilion\n\nCHIEF COMPLAINT:\nPatient presents with acute sub-sternal tightness radiating to left shoulder and intermittent shortness of breath for 36 hours. Secondary complaint of chronic mechanical lower back stiffness.\n\nHISTORY OF PRESENT ILLNESS:\nMs. Vance reports acute onset of pressure-like retrosternal chest pain (7/10 severity) starting yesterday evening, exacerbated by deep inspiration. Associated with mild dyspnea and diaphoresis. Denies recent trauma. Has history of chronic lumbar strain for which she takes occasional ibuprofen.\n\nPHYSICAL EXAMINATION:\n- Vitals: BP 142/88, HR 94 regular, RR 20, SpO2 96% on room air, Temp 98.6F.\n- Cardiovascular: Regular rate and rhythm, normal S1/S2, no murmurs, rubs, or gallops.\n- Respiratory: Decreased breath sounds at right lung base, mild inspiratory wheeze, no crackles.\n- Musculoskeletal: Paraspinal lumbar tenderness without radiculopathy.\n\nDIAGNOSTIC WORKUP ORDERED:\n1. 12-lead ECG (CPT 93000) - normal sinus rhythm.\n2. Chest Radiograph Single View (CPT 71045) - ordered STAT to rule out acute pneumothorax, pulmonary consolidation, or thoracic aortic pathology given acute chest discomfort.\n\nASSESSMENT & PLAN:\n1. Acute Chest Pain, unspecified (ICD-10: R07.9) - Primary etiology for urgent imaging. Stat chest radiograph ordered to evaluate pulmonary parenchymal infiltration or acute cardiothoracic etiology.\n2. Dyspnea, unspecified (ICD-10: R06.02) - Secondary respiratory symptom.\n3. Low back pain (ICD-10: M54.5) - Incidental chronic baseline complaint, stable, conservative management continued.\n\nSigned electronically by: Marcus Reed, MD (02/14/2026 11:42 EST)',
    sampleResponseJson: {
      'request_id': 'REQ-CLAIM-2026-001',
      'status': 'APPROVED',
      'iterations_count': 2,
      'remediation_plan': {
        'triage_summary':
            'Audit of Claim CLM-90281-A identifies root cause: CO-50 denial on CPT 71045.',
        'root_cause_analysis':
            'Clinical EHR documentation establishes valid medical indications (R07.9), but claim intake crosswalk mistakenly listed non-qualifying code (M54.5), triggering adverse benefit determination CO-50.',
        'required_evidence_criteria': [
          'Extract direct clinical quotations of physician Dr. Marcus Reed\'s objective findings.',
          'Cite qualifying diagnostic code (R07.9) and applicable coverage policies.',
          'Invoke federal ERISA 29 CFR § 2560.503-1 / ACA § 2719 statutory appeal review standards.',
          'Demand immediate claim overturn and re-adjudication.'
        ],
        'recommended_icd10': 'R07.9',
        'statutory_citations': [
          'ERISA 29 U.S.C. § 1133 / 29 CFR § 2560.503-1',
          'Patient Protection and Affordable Care Act § 2719',
          'Social Security Act § 1862(a)(1)(A)'
        ],
        'matched_guidelines_count': 1,
        'target_icd10': 'R07.9'
      },
      'audit_scorecard': {
        'score': 100,
        'passed': true,
        'status': 'APPROVED',
        'critique_points': []
      },
      'critique_history': [
        {
          'iteration': 1,
          'timestamp': '2026-10-23T17:33:53.716041+00:00',
          'draft_summary':
              'Statutory Appeal Package for CLM-90281-A (71045) - Initial Draft',
          'draft_package': {
            'summary':
                'Statutory Appeal Package for CLM-90281-A (71045) - Initial Draft',
            'appeal_letter':
                'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-02-14\nTo: Appeals & Grievance Department, Anthem Blue Cross Blue Shield\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-90281-A\nPatient: Eleanor Vance | Member ID: ANT-8829104 | DOS: 2026-02-14\nDisputed Service: CPT 71045 | Denial Code: CO-50 | Amount: USD 345.00\n\n1. STATEMENT OF DISPUTE\nThis letter constitutes a timely, formal appeal pursuant to 29 U.S.C. § 1133 and 29 C.F.R. § 2560.503-1 disputing the adverse benefit determination issued for CPT 71045. The denial under code CO-50 is erroneous and contrary to clinical record proof and established coverage guidelines.',
            'statutory_citations': [
              'ERISA 29 U.S.C. § 1133',
              '29 C.F.R. § 2560.503-1(h)(2)'
            ],
            'clinical_evidence': [
              {
                'source': 'Treating Physician (Dr. Marcus Reed) Encounter Note',
                'finding':
                    'ASSESSMENT & PLAN: 1. Acute Chest Pain, unspecified (ICD-10: R07.9) - Primary etiology for urgent imaging.',
                'primary_icd10': 'R07.9'
              }
            ],
            'coding_crosswalk': {
              'cpt_code': '71045',
              'billed_icd10': 'M54.5',
              'corrected_icd10': 'R07.9',
              'modifier_applied': null
            }
          },
          'critique': {
            'passed': false,
            'score': 74,
            'status': 'CRITIQUE_REVISION_REQUESTED',
            'summary':
                'Appeal packet requires strengthening of verbatim physician quotes and explicit ERISA full & fair review standard citations.',
            'critique_points': [
              'Mandatory Evidence Gap: Incorporate explicit verbatim quote from treating physician note.',
              'Coding Crosswalk: Explicitly crosswalk denial code CO-50 with qualifying ICD-10 R07.9.',
              'Statutory Citation: Include 29 CFR § 2560.503-1(h)(2) full & fair review standard.'
            ],
            'audit_findings': {
              'clinical_evidence_verified': true,
              'statutory_citations_compliant': false,
              'coding_crosswalk_validated': true,
              'precedent_match_score': 0.8
            }
          },
          'status': 'CRITIQUE_REVISION_REQUESTED',
          'passed_audit': false,
          'audit_score': 74
        },
        {
          'iteration': 2,
          'timestamp': '2026-10-23T17:33:56.161676+00:00',
          'draft_summary':
              'Statutory Appeal Package for CLM-90281-A (71045) - Revised',
          'draft_package': {
            'summary':
                'Statutory Appeal Package for CLM-90281-A (71045) - Revised',
            'appeal_letter':
                'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-02-14\nTo: Appeals & Grievance Department, Anthem Blue Cross Blue Shield\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-90281-A\nPatient: Eleanor Vance | DOB: 04/12/1968\nMember ID: ANT-8829104 | Date of Service: 2026-02-14\nDisputed Service: CPT 71045 | Disputed Denial Code: CO-50\nClaim Amount: USD 345.00\n\n1. STATEMENT OF DISPUTE\nThis letter constitutes a timely, formal appeal pursuant to 29 U.S.C. § 1133 and 29 C.F.R. § 2560.503-1 disputing the adverse benefit determination issued for CPT 71045. The denial under code CO-50 is erroneous and contrary to clinical record proof and established coverage guidelines.\n\n2. CLINICAL FACTUAL SUBSTANTIATION & DIRECT EHR EVIDENCE\nThe medical record clearly establishes that the disputed service was medically necessary and fully indicated.\nTreating Physician Documentation:\n"ASSESSMENT & PLAN: 1. Acute Chest Pain, unspecified (ICD-10: R07.9) - Primary etiology for urgent imaging. Stat chest radiograph ordered to evaluate pulmonary parenchymal infiltration or acute cardiothoracic etiology. 2. Dyspnea, unspecified (ICD-10: R06.02) - Secondary respiratory symptom."\nVerbatim Clinical Findings:\n- Acute presentation documented by Dr. Marcus Reed.\n- Primary diagnostic indication: R07.9.\n- Secondary baseline complaint (M54.5) was erroneously billed as primary reason for service during registration intake.\n\n3. STATUTORY & CODING CROSSWALK JUSTIFICATION\nUnder CMS Guidelines and ERISA regulations:\n- Primary Qualifying Diagnosis: ICD-10 R07.9\n- Procedure: CPT 71045\n- Statutory Precedent: ERISA 29 C.F.R. § 2560.503-1(h)(2) requires a full and fair review taking into account all comments, documents, and records submitted.\n\n4. DEMAND FOR REMEDY\nWe respectfully demand that Anthem Blue Cross Blue Shield overturn this adverse determination immediately and process CPT 71045 for full contractual payment within 30 statutory days.',
            'statutory_citations': [
              'ERISA 29 U.S.C. § 1133',
              '29 C.F.R. § 2560.503-1(h)(2)',
              'Affordable Care Act § 2719 (45 CFR § 147.136)',
              'Social Security Act § 1862(a)(1)(A)'
            ],
            'clinical_evidence': [
              {
                'source': 'Treating Physician (Dr. Marcus Reed) Encounter Note',
                'finding':
                    'ASSESSMENT & PLAN: 1. Acute Chest Pain, unspecified (ICD-10: R07.9) - Primary etiology for urgent imaging. Stat chest radiograph ordered to evaluate pulmonary parenchymal infiltration or acute cardiothoracic etiology.',
                'primary_icd10': 'R07.9'
              }
            ],
            'coding_crosswalk': {
              'cpt_code': '71045',
              'billed_icd10': 'M54.5',
              'corrected_icd10': 'R07.9',
              'modifier_applied': null
            }
          },
          'critique': {
            'passed': true,
            'score': 100,
            'status': 'APPROVED',
            'summary':
                'Appeal packet for CLM-90281-A fully satisfies all clinical and statutory audit criteria. Verbatim proof from Dr. Marcus Reed, ICD-10 R07.9 crosswalk, and legal mandates are thoroughly substantiated.',
            'critique_points': [],
            'audit_findings': {
              'clinical_evidence_verified': true,
              'statutory_citations_compliant': true,
              'coding_crosswalk_validated': true,
              'precedent_match_score': 1.0
            }
          },
          'status': 'APPROVED',
          'passed_audit': true,
          'audit_score': 100
        }
      ],
      'appeal_package': {
        'summary': 'Statutory Appeal Package for CLM-90281-A (71045) - Revised',
        'appeal_letter':
            'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-02-14\nTo: Appeals & Grievance Department, Anthem Blue Cross Blue Shield\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-90281-A\nPatient: Eleanor Vance | DOB: 04/12/1968\nMember ID: ANT-8829104 | Date of Service: 2026-02-14\nDisputed Service: CPT 71045 | Disputed Denial Code: CO-50\nClaim Amount: USD 345.00\n\n1. STATEMENT OF DISPUTE\nThis letter constitutes a timely, formal appeal pursuant to 29 U.S.C. § 1133 and 29 C.F.R. § 2560.503-1 disputing the adverse benefit determination issued for CPT 71045. The denial under code CO-50 is erroneous and contrary to clinical record proof and established coverage guidelines.\n\n2. CLINICAL FACTUAL SUBSTANTIATION & DIRECT EHR EVIDENCE\nThe medical record clearly establishes that the disputed service was medically necessary and fully indicated.\nTreating Physician Documentation:\n"ASSESSMENT & PLAN: 1. Acute Chest Pain, unspecified (ICD-10: R07.9) - Primary etiology for urgent imaging. Stat chest radiograph ordered to evaluate pulmonary parenchymal infiltration or acute cardiothoracic etiology. 2. Dyspnea, unspecified (ICD-10: R06.02) - Secondary respiratory symptom."\nVerbatim Clinical Findings:\n- Acute presentation documented by Dr. Marcus Reed.\n- Primary diagnostic indication: R07.9.\n- Secondary baseline complaint (M54.5) was erroneously billed as primary reason for service during registration intake.\n\n3. STATUTORY & CODING CROSSWALK JUSTIFICATION\nUnder CMS Guidelines and ERISA regulations:\n- Primary Qualifying Diagnosis: ICD-10 R07.9\n- Procedure: CPT 71045\n- Statutory Precedent: ERISA 29 C.F.R. § 2560.503-1(h)(2) requires a full and fair review taking into account all comments, documents, and records submitted.\n\n4. DEMAND FOR REMEDY\nWe respectfully demand that Anthem Blue Cross Blue Shield overturn this adverse determination immediately and process CPT 71045 for full contractual payment within 30 statutory days.',
        'statutory_citations': [
          'ERISA 29 U.S.C. § 1133',
          '29 C.F.R. § 2560.503-1(h)(2)',
          'Affordable Care Act § 2719 (45 CFR § 147.136)',
          'Social Security Act § 1862(a)(1)(A)'
        ],
        'clinical_evidence': [
          {
            'source': 'Treating Physician (Dr. Marcus Reed) Encounter Note',
            'finding':
                'ASSESSMENT & PLAN: 1. Acute Chest Pain, unspecified (ICD-10: R07.9) - Primary etiology for urgent imaging. Stat chest radiograph ordered to evaluate pulmonary parenchymal infiltration or acute cardiothoracic etiology.',
            'primary_icd10': 'R07.9'
          }
        ],
        'coding_crosswalk': {
          'cpt_code': '71045',
          'billed_icd10': 'M54.5',
          'corrected_icd10': 'R07.9',
          'modifier_applied': null
        }
      },
      'h_mem_summary': {
        'request_id': 'REQ-CLAIM-2026-001',
        'created_at': '2026-10-23T17:33:49.855095+00:00',
        'claim_id': 'CLM-90281-A',
        'denial_code': 'CO-50',
        'matched_policy_count': 1,
        'iteration_count': 2,
        'latest_audit_score': 100,
        'final_status': 'APPROVED'
      },
      'trace_summary': [
        {
          'agent': 'Orchestrator',
          'action': 'INITIALIZE_PIPELINE',
          'status': 'INITIALIZED',
          'model': 'meterless/nightshift'
        },
        {
          'agent': 'ZetarisAdapter',
          'action': 'ZETARIS_CONNECTION_FAILURE',
          'status': 'FALLBACK_TRIGGERED',
          'model': 'meterless/nightshift'
        },
        {
          'agent': 'ZetarisAdapter',
          'action': 'MOCK_LAKEHOUSE_QUERY',
          'status': 'SUCCESS',
          'model': 'meterless/nightshift'
        },
        {
          'agent': 'PlannerAgent',
          'action': 'LOCAL_REASONING_SYNTHESIS',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'PlannerAgent',
          'action': 'SYNTHESIZE_REMEDIATION_PLAN',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'ExecutorAgent',
          'action': 'GENERATE_INITIAL_APPEAL_DRAFT',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'EvaluatorAgent',
          'action': 'CRITIQUE_FLAG_REVISION_REQUESTED',
          'status': 'CRITIQUE_REVISION_REQUESTED',
          'model': 'meterless/deep'
        },
        {
          'agent': 'ExecutorAgent',
          'action': 'REVISE_APPEAL_PACKAGE',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'EvaluatorAgent',
          'action': 'APPROVE_APPEAL_PACKAGE',
          'status': 'APPROVED',
          'model': 'meterless/deep'
        }
      ]
    },
  ),

  // Preset 2: CO-16 Missing Clinical Documentation (Consult 99244)
  PresetClaim(
    id: 'preset_2',
    title: 'Preset 2: CO-16 Missing Documentation',
    subtitle: 'Consultation (CPT 99244) | Arthur Pendelton',
    denialCode: 'CO-16',
    deniedCpt: '99244',
    deniedAmount: 580.00,
    payerName: 'UnitedHealthcare Commercial',
    patientName: 'Arthur Pendelton',
    claimId: 'CLM-44820-B',
    patientDob: '1954-11-23',
    memberId: 'UHC-9938210',
    denialReason:
        'Claim/service lacks information or has submission/billing error(s) which is needed for adjudication. Missing supporting clinical consultation documentation.',
    clinicalNotes:
        'SPECIALTY CONSULTATION NOTE\nPatient: Arthur Pendelton | DOB: 11/23/1954 | DOS: 01/20/2026\nConsulting Specialist: Dr. Evelyn Zhao, MD (Endocrinology & Metabolism, NPI: 1049281745)\nRequesting Physician: Dr. Robert Miller, MD (PCP, Internal Medicine, NPI: 1938472910)\nFacility: Valley Health Endocrinology Specialists\n\nREASON FOR CONSULTATION:\nFormal written referral received on 01/15/2026 from PCP Dr. Robert Miller requesting specialized endocrine opinion and management recommendations for brittle glycemic control (HbA1c 10.4% despite dual oral hypoglycemic therapy) and symptomatic diabetic polyneuropathy.\n\nHISTORY OF PRESENT ILLNESS:\n71-year-old male with poorly controlled Type 2 Diabetes Mellitus (ICD-10: E11.9) referred for expert evaluation. Reports recurrent fasting hyperglycemias (220-280 mg/dL) and painful distal bilateral lower extremity paresthesias.\n\nCOMPREHENSIVE EXAMINATION & COUNSELING (Total face-to-face duration: 62 minutes):\n- Comprehensive review of home glucose logs, nutritional habits, and medication adherence.\n- Neurological exam: Reduced vibration sensation bilaterally via 128Hz tuning fork, absent Achilles reflexes bilaterally.\n- Foot exam: Monofilament testing abnormal at 4/10 sites bilaterally, skin intact, pedal pulses 2+.\n\nASSESSMENT & PLAN:\n1. Type 2 Diabetes Mellitus with uncontrolled hyperglycemia (ICD-10: E11.69 / E11.9).\n2. Diabetic peripheral neuropathy (ICD-10: E11.40).\n3. Initiated basal insulin glargine 14 units nightly; titrated metformin to 1000 mg BID.\n4. Prescribed continuous glucose monitor (Dexcom G7) and referred for diabetic self-management education.\n\nWRITTEN CONSULTATION REPORT STATUS:\nA full formal 4-page written consultation report detailing diagnostic findings and therapeutic recommendations was transmitted via secure EHR direct messaging to requesting provider Dr. Robert Miller on 01/20/2026 at 16:30 EST.\n\nSigned: Evelyn Zhao, MD, Endocrinology (01/20/2026 16:45 EST)',
    sampleResponseJson: {
      'request_id': 'REQ-CLAIM-2026-002',
      'status': 'APPROVED',
      'iterations_count': 2,
      'remediation_plan': {
        'triage_summary':
            'Audit of Claim CLM-44820-B identifies root cause: CO-16 denial on CPT 99244.',
        'root_cause_analysis':
            'Clinical EHR documentation establishes valid medical indications (E11.9), and complete referral and report documentation exists in EHR record to overcome CO-16 missing documentation denial.',
        'required_evidence_criteria': [
          'Extract direct clinical quotations of physician Dr. Evelyn Zhao\'s objective findings.',
          'Verify PCP referral record and formal 4-page consultation report transmission timestamp.',
          'Invoke federal ERISA 29 CFR § 2560.503-1 / ACA § 2719 statutory appeal review standards.',
          'Demand immediate claim overturn and re-adjudication.'
        ],
        'recommended_icd10': 'E11.9',
        'statutory_citations': [
          'ERISA 29 U.S.C. § 1133 / 29 CFR § 2560.503-1',
          'Patient Protection and Affordable Care Act § 2719',
          'Social Security Act § 1862(a)(1)(A)'
        ],
        'matched_guidelines_count': 1,
        'target_icd10': 'E11.9'
      },
      'audit_scorecard': {
        'score': 100,
        'passed': true,
        'status': 'APPROVED',
        'critique_points': []
      },
      'critique_history': [
        {
          'iteration': 1,
          'timestamp': '2026-10-23T17:34:00.325424+00:00',
          'draft_summary':
              'Statutory Appeal Package for CLM-44820-B (99244) - Initial Draft',
          'draft_package': {
            'summary':
                'Statutory Appeal Package for CLM-44820-B (99244) - Initial Draft',
            'appeal_letter':
                'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-01-20\nTo: Appeals & Grievance Department, UnitedHealthcare Commercial\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-44820-B\nPatient: Arthur Pendelton | Member ID: UHC-9938210 | DOS: 2026-01-20\nDisputed Service: CPT 99244 | Disputed Denial Code: CO-16\nClaim Amount: USD 580.00',
            'statutory_citations': ['ERISA 29 U.S.C. § 1133'],
            'clinical_evidence': [
              {
                'source':
                    'Treating Physician (Dr. Evelyn Zhao) Encounter Note',
                'finding':
                    'ASSESSMENT & PLAN: 1. Type 2 Diabetes Mellitus with uncontrolled hyperglycemia (ICD-10: E11.69 / E11.9).',
                'primary_icd10': 'E11.9'
              }
            ],
            'coding_crosswalk': {
              'cpt_code': '99244',
              'billed_icd10': 'E11.9',
              'corrected_icd10': 'E11.9',
              'modifier_applied': null
            }
          },
          'critique': {
            'passed': false,
            'score': 74,
            'status': 'CRITIQUE_REVISION_REQUESTED',
            'summary':
                'Documentation verification needed for PCP referral and consultation report transmission proof.',
            'critique_points': [
              'Mandatory Evidence Gap: Incorporate explicit verbatim quote from treating specialist note regarding referral and transmitted report.',
              'Coding Crosswalk: Crosswalk CPT 99244 with documentation criteria.',
              'Statutory Citation: Include 29 CFR § 2560.503-1(h)(2) full & fair review standard.'
            ],
            'audit_findings': {
              'clinical_evidence_verified': true,
              'statutory_citations_compliant': false,
              'coding_crosswalk_validated': true,
              'precedent_match_score': 0.8
            }
          },
          'status': 'CRITIQUE_REVISION_REQUESTED',
          'passed_audit': false,
          'audit_score': 74
        },
        {
          'iteration': 2,
          'timestamp': '2026-10-23T17:34:02.161676+00:00',
          'draft_summary':
              'Statutory Appeal Package for CLM-44820-B (99244) - Revised',
          'draft_package': {
            'summary':
                'Statutory Appeal Package for CLM-44820-B (99244) - Revised',
            'appeal_letter':
                'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-01-20\nTo: Appeals & Grievance Department, UnitedHealthcare Commercial\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-44820-B\nPatient: Arthur Pendelton | Member ID: UHC-9938210 | DOS: 2026-01-20\nDisputed Service: CPT 99244 | Disputed Denial Code: CO-16\nClaim Amount: USD 580.00\n\n1. STATEMENT OF DISPUTE\nThis letter constitutes a timely, formal appeal pursuant to 29 U.S.C. § 1133 and 29 C.F.R. § 2560.503-1 disputing the adverse benefit determination issued for CPT 99244. The denial under code CO-16 for alleged missing documentation is contradicted by the enclosed complete consultation file.\n\n2. CLINICAL FACTUAL SUBSTANTIATION & DIRECT EHR EVIDENCE\nThe specialist medical record substantiates the 62-minute consultation:\n"REASON FOR CONSULTATION: Formal written referral received on 01/15/2026 from PCP Dr. Robert Miller requesting specialized endocrine opinion... WRITTEN CONSULTATION REPORT STATUS: A full formal 4-page written consultation report was transmitted via secure EHR direct messaging on 01/20/2026."\n\n3. STATUTORY JUSTIFICATION\nUnder ERISA 29 C.F.R. § 2560.503-1(h)(2), UnitedHealthcare is legally bound to conduct a full and fair review of all submitted documentation.\n\n4. DEMAND FOR REMEDY\nOverturn CO-16 denial immediately and adjudicate CPT 99244 for full payment within statutory timelines.',
            'statutory_citations': [
              'ERISA 29 U.S.C. § 1133',
              '29 C.F.R. § 2560.503-1(h)(2)',
              'Affordable Care Act § 2719'
            ],
            'clinical_evidence': [
              {
                'source': 'Treating Specialist (Dr. Evelyn Zhao) Consult Note',
                'finding':
                    'Formal written referral verified and 4-page report transmitted to Dr. Robert Miller on 01/20/2026.',
                'primary_icd10': 'E11.9'
              }
            ],
            'coding_crosswalk': {
              'cpt_code': '99244',
              'billed_icd10': 'E11.9',
              'corrected_icd10': 'E11.9',
              'modifier_applied': null
            }
          },
          'critique': {
            'passed': true,
            'score': 100,
            'status': 'APPROVED',
            'summary':
                'Appeal packet for CLM-44820-B meets all statutory and clinical evidentiary standards. Documentation gap fully resolved.',
            'critique_points': [],
            'audit_findings': {
              'clinical_evidence_verified': true,
              'statutory_citations_compliant': true,
              'coding_crosswalk_validated': true,
              'precedent_match_score': 1.0
            }
          },
          'status': 'APPROVED',
          'passed_audit': true,
          'audit_score': 100
        }
      ],
      'appeal_package': {
        'summary': 'Statutory Appeal Package for CLM-44820-B (99244) - Revised',
        'appeal_letter':
            'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-01-20\nTo: Appeals & Grievance Department, UnitedHealthcare Commercial\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-44820-B\nPatient: Arthur Pendelton | Member ID: UHC-9938210 | DOS: 2026-01-20\nDisputed Service: CPT 99244 | Disputed Denial Code: CO-16\nClaim Amount: USD 580.00\n\n1. STATEMENT OF DISPUTE\nThis letter constitutes a timely, formal appeal pursuant to 29 U.S.C. § 1133 and 29 C.F.R. § 2560.503-1 disputing the adverse benefit determination issued for CPT 99244. The denial under code CO-16 for alleged missing documentation is contradicted by the enclosed complete consultation file.\n\n2. CLINICAL FACTUAL SUBSTANTIATION & DIRECT EHR EVIDENCE\nThe specialist medical record substantiates the 62-minute consultation:\n"REASON FOR CONSULTATION: Formal written referral received on 01/15/2026 from PCP Dr. Robert Miller requesting specialized endocrine opinion... WRITTEN CONSULTATION REPORT STATUS: A full formal 4-page written consultation report was transmitted via secure EHR direct messaging on 01/20/2026."\n\n3. STATUTORY JUSTIFICATION\nUnder ERISA 29 C.F.R. § 2560.503-1(h)(2), UnitedHealthcare is legally bound to conduct a full and fair review of all submitted documentation.\n\n4. DEMAND FOR REMEDY\nOverturn CO-16 denial immediately and adjudicate CPT 99244 for full payment within statutory timelines.',
        'statutory_citations': [
          'ERISA 29 U.S.C. § 1133',
          '29 C.F.R. § 2560.503-1(h)(2)',
          'Affordable Care Act § 2719'
        ],
        'clinical_evidence': [
          {
            'source': 'Treating Specialist (Dr. Evelyn Zhao) Consult Note',
            'finding':
                'Formal written referral verified and 4-page report transmitted to Dr. Robert Miller on 01/20/2026.',
            'primary_icd10': 'E11.9'
          }
        ],
        'coding_crosswalk': {
          'cpt_code': '99244',
          'billed_icd10': 'E11.9',
          'corrected_icd10': 'E11.9',
          'modifier_applied': null
        }
      },
      'h_mem_summary': {
        'request_id': 'REQ-CLAIM-2026-002',
        'created_at': '2026-10-23T17:34:00.000000+00:00',
        'claim_id': 'CLM-44820-B',
        'denial_code': 'CO-16',
        'matched_policy_count': 1,
        'iteration_count': 2,
        'latest_audit_score': 100,
        'final_status': 'APPROVED'
      },
      'trace_summary': [
        {
          'agent': 'Orchestrator',
          'action': 'INITIALIZE_PIPELINE',
          'status': 'INITIALIZED',
          'model': 'meterless/nightshift'
        },
        {
          'agent': 'PlannerAgent',
          'action': 'SYNTHESIZE_REMEDIATION_PLAN',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'ExecutorAgent',
          'action': 'GENERATE_INITIAL_APPEAL_DRAFT',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'EvaluatorAgent',
          'action': 'CRITIQUE_FLAG_REVISION_REQUESTED',
          'status': 'CRITIQUE_REVISION_REQUESTED',
          'model': 'meterless/deep'
        },
        {
          'agent': 'ExecutorAgent',
          'action': 'REVISE_APPEAL_PACKAGE',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'EvaluatorAgent',
          'action': 'APPROVE_APPEAL_PACKAGE',
          'status': 'APPROVED',
          'model': 'meterless/deep'
        }
      ]
    },
  ),

  // Preset 3: CO-18 Duplicate Claim (Modifier -59 / -25)
  PresetClaim(
    id: 'preset_3',
    title: 'Preset 3: CO-18 Duplicate Claim',
    subtitle: 'Outpatient Visit (CPT 99214) | Dominic Rossi',
    denialCode: 'CO-18',
    deniedCpt: '99214',
    deniedAmount: 215.00,
    payerName: 'Aetna Health',
    patientName: 'Dominic Rossi',
    claimId: 'CLM-77192-C',
    patientDob: '1982-08-30',
    memberId: 'AET-3391024',
    denialReason:
        'Exact duplicate claim/service. Line item adjudicated as previously submitted or bundled under same-day procedure.',
    clinicalNotes:
        'AMBULATORY ENCOUNTER & PROCEDURE NOTE\nPatient: Dominic Rossi | DOB: 08/30/1982 | DOS: 02/05/2026\nTreating Physician: Dr. Sarah Jenkins, MD (Physical Medicine & Rehabilitation, NPI: 1827364501)\nFacility: Metro Spine & Pain Care Specialists\n\nCHIEF COMPLAINT:\nFollow-up evaluation for severe refractory lumbosacral radiculopathy and pre-procedure evaluation for scheduled trigger point injections.\n\nEVALUATION & MANAGEMENT COMPONENT (Separate and Distinct - Modifier -25 justification):\nPatient evaluated in exam room 4 prior to any injection. Thorough interval medical history taken regarding new onset radiating numbness into left lateral calf. Medication reconciliation performed (adjusting gabapentin from 300mg TID to 600mg TID due to breakthrough pain). Comprehensive discussion of MRI findings (L4-L5 disc protrusion) and risks/benefits of corticosteroid intervention. Independent medical decision making of moderate complexity (MDM Level 4) executed distinctly prior to the injection procedure.\n\nPROCEDURE PERFORMED (CPT 20552):\nTrigger point injections, 2 muscles (left lumbar iliocostalis and left piriformis). Performed under strict sterile technique with 1% lidocaine 4ml total. Patient tolerated well without complication.\n\nBILLING & CODING JUSTIFICATION:\nThe Evaluation and Management service (CPT 99214-25) represents a significant, separately identifiable medical service above and beyond the usual pre-procedure and post-procedure work associated with CPT 20552. Both services occurred on the same date of service (02/05/2026) but warrant distinct unbundled reimbursement with appropriate Modifier -25 / -59 attachment.\n\nSigned: Sarah Jenkins, MD, PM&R (02/05/2026 15:15 EST)',
    sampleResponseJson: {
      'request_id': 'REQ-CLAIM-2026-003',
      'status': 'APPROVED',
      'iterations_count': 2,
      'remediation_plan': {
        'triage_summary':
            'Audit of Claim CLM-77192-C identifies root cause: CO-18 denial on CPT 99214.',
        'root_cause_analysis':
            'Clinical EHR documentation establishes valid medical indications (L4-L5 radiculopathy) and substantial separately identifiable Evaluation & Management service, warranting Modifier -25 / -59 unbundling from procedure CPT 20552.',
        'required_evidence_criteria': [
          'Extract direct clinical quotations of physician Dr. Sarah Jenkins\'s objective findings.',
          'Substantiate distinct Medical Decision Making (MDM Level 4) pre-procedure.',
          'Crosswalk CPT 99214 with Modifier -25 to overcome CO-18 bundling determination.',
          'Invoke federal ERISA 29 CFR § 2560.503-1 / ACA § 2719 statutory appeal review standards.'
        ],
        'recommended_icd10': 'M54.16',
        'statutory_citations': [
          'ERISA 29 U.S.C. § 1133 / 29 CFR § 2560.503-1',
          'Patient Protection and Affordable Care Act § 2719',
          'CMS NCCI Policy Manual Chapter 1, Section E'
        ],
        'matched_guidelines_count': 1,
        'target_icd10': 'M54.16'
      },
      'audit_scorecard': {
        'score': 100,
        'passed': true,
        'status': 'APPROVED',
        'critique_points': []
      },
      'critique_history': [
        {
          'iteration': 1,
          'timestamp': '2026-10-23T17:34:07.297856+00:00',
          'draft_summary':
              'Statutory Appeal Package for CLM-77192-C (99214) - Initial Draft',
          'draft_package': {
            'summary':
                'Statutory Appeal Package for CLM-77192-C (99214) - Initial Draft',
            'appeal_letter':
                'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-02-05\nTo: Appeals & Grievance Department, Aetna Health\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-77192-C\nPatient: Dominic Rossi | Member ID: AET-3391024 | DOS: 2026-02-05\nDisputed Service: CPT 99214 | Disputed Denial Code: CO-18\nClaim Amount: USD 215.00',
            'statutory_citations': ['ERISA 29 U.S.C. § 1133'],
            'clinical_evidence': [
              {
                'source':
                    'Treating Physician (Dr. Sarah Jenkins) Encounter Note',
                'finding':
                    'EVALUATION & MANAGEMENT COMPONENT: Significant, separately identifiable service prior to procedure.',
                'primary_icd10': 'M54.16'
              }
            ],
            'coding_crosswalk': {
              'cpt_code': '99214',
              'billed_icd10': 'M54.5',
              'corrected_icd10': 'M54.16',
              'modifier_applied': '-25'
            }
          },
          'critique': {
            'passed': false,
            'score': 74,
            'status': 'CRITIQUE_REVISION_REQUESTED',
            'summary':
                'Appeal draft requires explicit quotation of pre-procedure MDM evaluation and NCCI Modifier -25 unbundling justification.',
            'critique_points': [
              'Mandatory Evidence Gap: Incorporate verbatim quotation regarding independent pre-procedure decision making.',
              'Coding Crosswalk: Explicitly specify Modifier -25 attachment to CPT 99214.',
              'Statutory Citation: Include 29 CFR § 2560.503-1(h)(2) full & fair review standard.'
            ],
            'audit_findings': {
              'clinical_evidence_verified': true,
              'statutory_citations_compliant': false,
              'coding_crosswalk_validated': true,
              'precedent_match_score': 0.85
            }
          },
          'status': 'CRITIQUE_REVISION_REQUESTED',
          'passed_audit': false,
          'audit_score': 74
        },
        {
          'iteration': 2,
          'timestamp': '2026-10-23T17:34:09.161676+00:00',
          'draft_summary':
              'Statutory Appeal Package for CLM-77192-C (99214) - Revised',
          'draft_package': {
            'summary':
                'Statutory Appeal Package for CLM-77192-C (99214) - Revised',
            'appeal_letter':
                'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-02-05\nTo: Appeals & Grievance Department, Aetna Health\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-77192-C\nPatient: Dominic Rossi | Member ID: AET-3391024 | DOS: 2026-02-05\nDisputed Service: CPT 99214-25 | Disputed Denial Code: CO-18\nClaim Amount: USD 215.00\n\n1. STATEMENT OF DISPUTE\nThis letter constitutes a timely, formal appeal pursuant to 29 U.S.C. § 1133 and 29 C.F.R. § 2560.503-1 disputing the adverse benefit determination issued for CPT 99214 under denial code CO-18 (duplicate / bundled). Clinical documentation establishes this was a distinct E/M service requiring Modifier -25.\n\n2. CLINICAL FACTUAL SUBSTANTIATION & DIRECT EHR EVIDENCE\nTreating Physician Documentation:\n"Patient evaluated in exam room 4 prior to any injection. Thorough interval medical history taken regarding new onset radiating numbness into left lateral calf. Medication reconciliation performed (adjusting gabapentin from 300mg TID to 600mg TID). Independent medical decision making of moderate complexity (MDM Level 4) executed distinctly prior to the injection procedure."\n\n3. STATUTORY & CODING CROSSWALK JUSTIFICATION\nUnder CMS NCCI manual guidelines and ERISA 29 C.F.R. § 2560.503-1(h)(2), modifier -25 validates distinct reimbursement for separately identifiable services on the same date.\n\n4. DEMAND FOR REMEDY\nOverturn CO-18 duplicate determination immediately and reprocess CPT 99214-25 for full payment.',
            'statutory_citations': [
              'ERISA 29 U.S.C. § 1133',
              '29 C.F.R. § 2560.503-1(h)(2)',
              'CMS NCCI Policy Manual Chapter 1, Section E'
            ],
            'clinical_evidence': [
              {
                'source':
                    'Treating Physician (Dr. Sarah Jenkins) Encounter Note',
                'finding':
                    'Medication reconciliation and distinct MDM Level 4 executed prior to trigger point injections.',
                'primary_icd10': 'M54.16'
              }
            ],
            'coding_crosswalk': {
              'cpt_code': '99214',
              'billed_icd10': 'M54.5',
              'corrected_icd10': 'M54.16',
              'modifier_applied': '-25'
            }
          },
          'critique': {
            'passed': true,
            'score': 100,
            'status': 'APPROVED',
            'summary':
                'Appeal packet for CLM-77192-C fully satisfies all clinical and statutory audit criteria. Distinct E/M service and Modifier -25 crosswalk confirmed.',
            'critique_points': [],
            'audit_findings': {
              'clinical_evidence_verified': true,
              'statutory_citations_compliant': true,
              'coding_crosswalk_validated': true,
              'precedent_match_score': 1.0
            }
          },
          'status': 'APPROVED',
          'passed_audit': true,
          'audit_score': 100
        }
      ],
      'appeal_package': {
        'summary': 'Statutory Appeal Package for CLM-77192-C (99214) - Revised',
        'appeal_letter':
            'FORMAL STATUTORY APPEAL FOR CLAIM RE-ADJUDICATION\nDate: 2026-02-05\nTo: Appeals & Grievance Department, Aetna Health\nRe: Formal First-Level Statutory Appeal against Denial of Claim CLM-77192-C\nPatient: Dominic Rossi | Member ID: AET-3391024 | DOS: 2026-02-05\nDisputed Service: CPT 99214-25 | Disputed Denial Code: CO-18\nClaim Amount: USD 215.00\n\n1. STATEMENT OF DISPUTE\nThis letter constitutes a timely, formal appeal pursuant to 29 U.S.C. § 1133 and 29 C.F.R. § 2560.503-1 disputing the adverse benefit determination issued for CPT 99214 under denial code CO-18 (duplicate / bundled). Clinical documentation establishes this was a distinct E/M service requiring Modifier -25.\n\n2. CLINICAL FACTUAL SUBSTANTIATION & DIRECT EHR EVIDENCE\nTreating Physician Documentation:\n"Patient evaluated in exam room 4 prior to any injection. Thorough interval medical history taken regarding new onset radiating numbness into left lateral calf. Medication reconciliation performed (adjusting gabapentin from 300mg TID to 600mg TID). Independent medical decision making of moderate complexity (MDM Level 4) executed distinctly prior to the injection procedure."\n\n3. STATUTORY & CODING CROSSWALK JUSTIFICATION\nUnder CMS NCCI manual guidelines and ERISA 29 C.F.R. § 2560.503-1(h)(2), modifier -25 validates distinct reimbursement for separately identifiable services on the same date.\n\n4. DEMAND FOR REMEDY\nOverturn CO-18 duplicate determination immediately and reprocess CPT 99214-25 for full payment.',
        'statutory_citations': [
          'ERISA 29 U.S.C. § 1133',
          '29 C.F.R. § 2560.503-1(h)(2)',
          'CMS NCCI Policy Manual Chapter 1, Section E'
        ],
        'clinical_evidence': [
          {
            'source': 'Treating Physician (Dr. Sarah Jenkins) Encounter Note',
            'finding':
                'Medication reconciliation and distinct MDM Level 4 executed prior to trigger point injections.',
            'primary_icd10': 'M54.16'
          }
        ],
        'coding_crosswalk': {
          'cpt_code': '99214',
          'billed_icd10': 'M54.5',
          'corrected_icd10': 'M54.16',
          'modifier_applied': '-25'
        }
      },
      'h_mem_summary': {
        'request_id': 'REQ-CLAIM-2026-003',
        'created_at': '2026-10-23T17:34:07.000000+00:00',
        'claim_id': 'CLM-77192-C',
        'denial_code': 'CO-18',
        'matched_policy_count': 1,
        'iteration_count': 2,
        'latest_audit_score': 100,
        'final_status': 'APPROVED'
      },
      'trace_summary': [
        {
          'agent': 'Orchestrator',
          'action': 'INITIALIZE_PIPELINE',
          'status': 'INITIALIZED',
          'model': 'meterless/nightshift'
        },
        {
          'agent': 'PlannerAgent',
          'action': 'SYNTHESIZE_REMEDIATION_PLAN',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'ExecutorAgent',
          'action': 'GENERATE_INITIAL_APPEAL_DRAFT',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'EvaluatorAgent',
          'action': 'CRITIQUE_FLAG_REVISION_REQUESTED',
          'status': 'CRITIQUE_REVISION_REQUESTED',
          'model': 'meterless/deep'
        },
        {
          'agent': 'ExecutorAgent',
          'action': 'REVISE_APPEAL_PACKAGE',
          'status': 'SUCCESS',
          'model': 'meterless/auto'
        },
        {
          'agent': 'EvaluatorAgent',
          'action': 'APPROVE_APPEAL_PACKAGE',
          'status': 'APPROVED',
          'model': 'meterless/deep'
        }
      ]
    },
  ),

  // Preset 4: Non-Clinical Document Rejection (Course Curriculum / Webinar)
  PresetClaim(
    id: 'preset_4',
    title: 'Preset 4: Non-Clinical Document Rejection',
    subtitle: 'Course Curriculum & Webinar Notes | Non-Medical',
    denialCode: 'CO-50',
    deniedCpt: '71045',
    deniedAmount: 420.00,
    payerName: 'UnitedHealthcare',
    patientName: 'Arthur Pendelton',
    claimId: 'CLM-REJECT-04',
    patientDob: '1975-08-20',
    memberId: 'UHC-9938102',
    denialReason:
        'These are non-covered services because this is not deemed a "medical necessity" by the payer based on the documentation submitted.',
    clinicalNotes:
        'Executive Masterclass Webinar Curriculum:\n'
        'Module 1: Introduction to AI Advisor Architectures and Agentic Workflows.\n'
        'Module 2: Dilaton scalar field theories and advanced algorithmic optimization.\n'
        'Prerequisites: Linear algebra and Python programming. Register online for certification.',
    sampleResponseJson: {
      'request_id': 'REQ-REJECT-DEMO-004',
      'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
      'iterations_count': 1,
      'remediation_plan': {
        'triage_summary':
            'Triage Rejected: Document uploaded for Claim CLM-REJECT-04 lacks clinical encounter data.',
        'root_cause_analysis':
            'Clinical validation failed. The provided notes do not contain clinical encounter data, diagnostic proof, or medical necessity evidence for CPT 71045.',
        'required_evidence_criteria': [
          'Valid clinical encounter note or EHR documentation',
          'Attending physician diagnosis and examination findings',
          'Documented medical necessity evidence'
        ],
        'recommended_icd10': null,
        'statutory_citations': [],
        'matched_guidelines_count': 0,
        'target_icd10': null
      },
      'audit_scorecard': {
        'score': 0,
        'passed': false,
        'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
        'critique':
            'The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.',
        'critique_points': [
          'The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.'
        ]
      },
      'critique_history': [
        {
          'iteration': 1,
          'timestamp': '2026-10-27T10:00:00.000000+00:00',
          'draft_summary':
              'Appeal Generation Aborted for Claim CLM-REJECT-04: Non-Clinical Document',
          'draft_package': {
            'summary':
                'Appeal Generation Aborted for Claim CLM-REJECT-04: Non-Clinical Document',
            'appeal_letter':
                'REJECTED: The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.',
            'statutory_citations': [],
            'clinical_evidence': [],
            'coding_crosswalk': {
              'cpt_code': '71045',
              'billed_icd10': '',
              'corrected_icd10': ''
            }
          },
          'critique': {
            'passed': false,
            'score': 0,
            'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
            'summary':
                'The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.',
            'critique_points': [
              'The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.'
            ],
            'audit_findings': {}
          },
          'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
          'passed_audit': false,
          'audit_score': 0
        }
      ],
      'appeal_package': {
        'summary':
            'Appeal Generation Aborted for Claim CLM-REJECT-04: Non-Clinical Document',
        'appeal_letter':
            'REJECTED: The uploaded document contains non-clinical / non-medical content. Statutory appeal cannot be synthesized without valid physician documentation.',
        'statutory_citations': [],
        'clinical_evidence': [],
        'coding_crosswalk': {
          'cpt_code': '71045',
          'billed_icd10': '',
          'corrected_icd10': ''
        }
      },
      'h_mem_summary': {
        'request_id': 'REQ-REJECT-DEMO-004',
        'claim_id': 'CLM-REJECT-04',
        'iterations_recorded': 1,
        'latest_audit_score': 0,
        'latest_audit_status': 'REJECTED_NON_CLINICAL_DOCUMENT',
        'policy_precedents_count': 0
      },
      'trace_summary': [
        {
          'agent': 'Orchestrator',
          'action': 'INITIALIZE_PIPELINE',
          'status': 'INITIALIZED',
          'model': 'meterless/nightshift'
        },
        {
          'agent': 'PlannerAgent',
          'action': 'REJECT_NON_CLINICAL_DOCUMENT',
          'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
          'model': 'meterless/clinical-validator'
        },
        {
          'agent': 'ExecutorAgent',
          'action': 'ABORT_NON_CLINICAL_APPEAL',
          'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
          'model': 'meterless/auto'
        },
        {
          'agent': 'EvaluatorAgent',
          'action': 'REJECT_NON_CLINICAL_DOCUMENT',
          'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
          'model': 'meterless/clinical-auditor'
        },
        {
          'agent': 'Orchestrator',
          'action': 'PIPELINE_REJECTED',
          'status': 'REJECTED_NON_CLINICAL_DOCUMENT',
          'model': 'meterless/auto'
        }
      ]
    },
  ),
];
