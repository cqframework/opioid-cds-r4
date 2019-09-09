library OpioidCDS_REC_09 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common
include OpioidCDS_Common_Config version '0.1.0' called Config
include OpioidCDS_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful

/*
**
**  Recommendation #9
**    Clinicians should review the patient’s history of controlled substance
**    prescriptions using state prescription drug monitoring program (PDMP) data
**    to determine whether the patient is receiving opioid dosages or dangerous
**    combinations that put him or her at high risk for overdose. Clinicians
**    should review PDMP data when starting opioid therapy for chronic pain
**    and periodically during opioid therapy for chronic pain, ranging from
**    every prescription to every 3 months
**    (recommendation category: A, evidence type: 4).
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds-r4/PlanDefinition-opioidcds-09.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<MedicationRequest>

context Patient

/*TODO: Are We Not Looking for 'active' status here?*/
define "Trigger Event Prescriptions":
  Common."Is Ambulatory Medication Request?"(ContextPrescriptions)

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "PDMP Data Not Reviewed in Past 90 Days":
  Config."PDMP Data Not Reviewed in Past 90 Days Criteria Enabled"
    and not (
      exists (
        [Procedure: Common."Review PDMP data procedure"] P
          where P.status ~ 'completed'
      )
      or exists (
        [Observation: Common."PDMP data review done Situation (the finding/situation is documented)"] O
          where O.status in { 'final', 'amended' }
      )
    )

define "Inclusion Criteria":
  "Validate Trigger Event"
    and OpioidReviewUseful."Opioid Review Would Be Useful"
    and "PDMP Data Not Reviewed in Past 90 Days"
    /* and not "Exclusion Criteria" */

define "Exclusion Criteria":
  false

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'Notify: PDMP data for this patient has not been reviewed in the past 90 days.'
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then 'Medication requests(s): ' + Combine(flatten(Common.GetMedicationNames("Trigger Event Prescriptions")), ', ')
  else null
