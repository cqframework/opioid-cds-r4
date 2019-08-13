library OpioidCDS_R4_REC_03 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_Common_Config version '0.1.0' called Config
include OpioidCDS_R4_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful

/*
**
**  Recommendation #3
**    Before starting and periodically during opioid therapy, clinicians should
**    discuss with patients known risks and realistic benefits of opioid therapy
**    and patient and clinician responsibilities for managing therapy
**    (recommendation category: A, evidence type: 3).
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-03.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Opioid Harms & Risks Counseling Lookback Period":
  Interval[Now() - 90 days, Now()]

define "Trigger Event Prescriptions":
  Common."Is Active Ambulatory Medication Request?"(ContextPrescriptions) TriggerScript
    where TriggerScript.code in Common."Extended Release Opioid with Ambulatory Abuse Potential"]

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "Inclusion Criteria":
  "Validate Trigger Event"
    and OpioidReviewUseful."Opioid Review Would Be Useful"
    and not ("Exclusion Criteria")


define "Exclusion Criteria":
  Config."Opioid Harms & Risks Discussion in Past 90 Days Criteria Enabled"
    and exists ("Documented Discussion of Opioid Harms and Risks in Past 90 Days Including Today")

  define "Documented Discussions of Opioid Harms and Risks in Past 90 Days Including Today":
    [Procedure: Common."Procedure For Counseling Regarding Potential Opioid Harms and Risks"] P
      where P.performed as dateTime during day of "Opioid Harms & Risks Counseling Lookback Period"
        and P.status ~ 'completed'

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'Recommend counseling regarding potential opioid harms and risks'
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then 'blah'
  else null
