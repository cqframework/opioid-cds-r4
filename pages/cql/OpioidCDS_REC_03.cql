library OpioidCDS_REC_03 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common
include OpioidCDS_Common_Config version '0.1.0' called Config
include OpioidCDS_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful
include ChronicPainDecisionPoints version '0.1.0' called ChronicPain

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
	http://build.fhir.org/ig/cqframework/opioid-cds-r4/PlanDefinition-opioidcds-03.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Opioid Harms & Risks Counseling Lookback Period":
  Interval[Now() - 90 days, Now() - 1 days]

define "Trigger Event Prescriptions":
  ( Common."Is Ambulatory Medication Request?"( ContextPrescriptions ) ) TriggerScript
    where TriggerScript.medication in Common."Extended Release Opioid with Ambulatory Abuse Potential"
      and ChronicPain."Chronic Pain Prescription"( TriggerScript )

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "Inclusion Criteria":
  "Validate Trigger Event"
    and OpioidReviewUseful."Opioid Review Would Be Useful"
    and "No Documented Discussions of Opioid Harms and Risks"

define "No Documented Discussions of Opioid Harms and Risks":
  Config."Opioid Harms & Risks Discussion in Past 90 Days Criteria Enabled"
    and not (
      exists ("Documented Discussions of Opioid Harms and Risks in Past 90 Days Excluding Today")
        or exists ("Ordered Discussions of Opioid Harms and Risks in Past 90 Days Excluding Today")
    )

define "Documented Discussions of Opioid Harms and Risks in Past 90 Days Excluding Today":
  [Procedure: Common."Documented discussion of opioid harms and risks"] P
    where FHIRHelpers.ToDateTime(P.performed as dateTime) during day of "Opioid Harms & Risks Counseling Lookback Period"
      and P.status ~ 'completed'

define "Ordered Discussions of Opioid Harms and Risks in Past 90 Days Excluding Today":
  [ServiceRequest: Common."Documented discussion of opioid harms and risks"] SR
    where FHIRHelpers.ToDateTime(SR.occurrence as dateTime) during day of "Opioid Harms & Risks Counseling Lookback Period"

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
    then 'Medication requests(s): ' + Combine(flatten(Common.GetMedicationNames("Trigger Event Prescriptions")), ', ')
  else null
