library OpioidCDS_REC_12 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common
include OpioidCDS_Common_Config version '0.1.0' called Config

/*
**
**  Recommendation #12
**    Clinicians should offer or arrange evidence-based treatment (usually
**    medication-assisted treatment with buprenorphine or methadone in combination
**    with behavioral therapies) for patients with opioid use disorder
**    (recommendation category: A, evidence type: 2).
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds-r4/PlanDefinition-opioidcds-12.html
*/


context Patient

define "Opioid Use Disorder Lookback Period":
  Interval[Now() - 90 days, Now()]

define "Trigger Event":
  true

/* define "Validate Trigger Event":
  exists( "Trigger Event" ) */

define "Not Receiving Evidence-Based Treatment for Opioid Use Disorder":
  Config."Evidence Based Treatment Criteria For Opioid Use Disorder"
    and not (
      AgeInYears() >=18
        and (
          exists (
            [MedicationRequest: Common."Buprenorphine and Methadone medications"] MR
              where MR.status in { 'active', 'completed' }
                and FHIRHelpers.ToDateTime(MR.authoredOn) during day of "Opioid Use Disorder Lookback Period"
          )
          or exists (
            [Procedure: Common."Substance misuse Behavioral counseling"] P
              where P.status ~ 'completed'
                and FHIRHelpers.ToDateTime(P.performed as dateTime) during day of "Opioid Use Disorder Lookback Period"
          )
        )
    )

define "Presence of Diagnosis of Opioid Use Disorder":
  exists (
    [Condition: Common."Opioid Misuse Disorders"] C
      where exists (
        C.clinicalStatus.coding Coding
          where FHIRHelpers.ToCode(Coding) ~ Common."Active Condition"
      )
          and FHIRHelpers.ToDateTime(C.recordedDate) during day of "Opioid Use Disorder Lookback Period"
    )

define "Positive Result from Opioid Use Disorder Evaluation Tool":
  /* TODO - FUTURE OPTION */ true

define "Inclusion Criteria":
  "Not Receiving Evidence-Based Treatment for Opioid Use Disorder"
    and "Presence of Diagnosis of Opioid Use Disorder"
    /* and "Positive Result from Opioid Use Disorder Evaluation Tool" */

define "Exclusion Criteria":
  false

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'Recommend opioid agonist or partial agonist treatment with methadone maintenance therapy or buprenorphine and/or behavioral therapy'
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then null
  else null
