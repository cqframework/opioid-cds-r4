library OpioidCDS_R4_REC_06 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_Common_Config version '0.1.0' called Config
include OpioidCDS_R4_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful

/*
**
**  Recommendation #6
**    Long-term opioid use often begins with treatment of acute pain. When opioids
**    are used for acute pain, clinicians should prescribe the lowest effective
**    dose of immediate-release opioids and should prescribe no greater quantity
**    than needed for the expected duration of pain severe enough to require
**    opioids. Three days or less will often be sufficient; more than seven days
**    will rarely be needed (recommendation category: A, evidence type: 4).
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-06.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Trigger Event Prescriptions":
  Common."Is Ambulatory Medication Request?"(ContextPrescriptions)

define "Order is to Treat Acute Pain":
  Config."Order is to Treat Acute Pain Enabled"
    and exists (
      "Trigger Event Prescriptions" TriggerScripts
        where Common.GetDurationInDays(TriggerScripts.dispenseRequest.expectedSupplyDuration) < 28
    )

define "Order is for Long-Acting Opioid":
  exists (
    "Trigger Event Prescriptions" TriggerScripts
      where TriggerScripts.medication in Common."Extended Release Opioid with Ambulatory Abuse Potential"
        or Common.GetDurationInDays(TriggerScripts.dispenseRequest.expectedSupplyDuration) > 7
  )

define "Validate Trigger Event":
  exists ("Trigger Event Prescriptions")

define "Inclusion Criteria":
  "Validate Trigger Event"
    and OpioidReviewUseful."Opioid Review Would Be Useful"
    and "Order is to Treat Acute Pain"
    and "Order is for Long-Acting Opioid"
    and not ("Exclusion Criteria")

define "Exclusion Criteria":
  false

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'Recommend limit therapy to <= 3 days to maximum of <= 7 days and to limit to immediate release opioids'
  else null

  define "Get Detail":
    if "Inclusion Criteria"
      then 'Medication requests(s): ' + Combine(Common.GetMedicationNames("Trigger Event Prescriptions"), ', ')
    else null
