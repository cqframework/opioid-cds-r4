library OpioidCDS_REC_02 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common
include OpioidCDS_Common_Config version '0.1.0' called Config
include OpioidCDS_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful
include OpioidCDS_OpioidNaive version '0.1.0' called OpioidNaive

/*
**
**  Recommendation #2
**    Before starting opioid therapy for chronic pain, clinicians should establish
**    treatment goals with all patients, including realistic goals for pain and
**    function, and should consider how opioid therapy will be discontinued if
**    benefits do not outweigh risks. Clinicians should continue opioid therapy
**    only if there is clinically meaningful improvement in pain and function
**    that outweighs risks to patient safety
**    (recommendation category: A, evidence type: 4).
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds-r4/PlanDefinition-opioidcds-02.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<MedicationRequest>

context Patient

// within the past 90 days (including the day of the visit)
define "Treatment Plan Lookback Period":
  Interval[Now() - 89 days, Now()]

define "Trigger Event Prescriptions":
(Common."Is Ambulatory Medication Request?"(ContextPrescriptions)) TriggerScript
    where Common.GetDurationInDays(TriggerScript.dispenseRequest.expectedSupplyDuration) >= 28

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "Inclusion Criteria":
    "Validate Trigger Event"
      and OpioidNaive."Is Opioid Naive"
      and OpioidReviewUseful."Opioid Review Would Be Useful"
      and "No Opioid Treatment Plan Created, was Edited or Reviewed in Past 90 Days?"

define "No Opioid Treatment Plan Created, was Edited or Reviewed in Past 90 Days?":
  Config."Opioid Treatment Plan Verification Enabled"
    and not (
      exists ("Opioid Treatment Plan Creation or Update in Past 90 Days")
        or "Had Opioid Treatment Plan Reviewed in Past 90 Days"
    )

define "Opioid Treatment Plan Creation or Update in Past 90 Days":
  [CarePlan] CP
    where exists (
        CP.category Category
          where FHIRHelpers.ToConcept(Category) ~ Common."Opioid treatment plan exists (a record artifact)"
      )
      and CP.status in { 'active', 'completed' }
      and (
        FHIRHelpers.ToDateTime(CP.created) during day of "Treatment Plan Lookback Period" or
          FHIRHelpers.ToDateTime(CP.meta.lastUpdated) during day of "Treatment Plan Lookback Period"
      )
      //and CP.author ~ "Trigger Event Prescriptions".recorder

define "Had Opioid Treatment Plan Reviewed in Past 90 Days":
  exists ([Observation: Common."Pain Management Treatment Plan Review"] O
      where (
        FHIRHelpers.ToDateTime(O.issued) during day of "Treatment Plan Lookback Period"
          or FHIRHelpers.ToDateTime(O.effective as dateTime) during day of "Treatment Plan Lookback Period"
      )
        //and O.performer ~ "Trigger Event Prescriptions".recorder
  )

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'Recommend creation, review or update of opioid treatment plan'
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then 'Medication requests(s): ' + Combine(Common.GetMedicationNames("Trigger Event Prescriptions"), ', ')
  else null
