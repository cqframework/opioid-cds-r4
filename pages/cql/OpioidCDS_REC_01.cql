library OpioidCDS_REC_01 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common
include OpioidCDS_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful
include OpioidCDS_OpioidNaive version '0.1.0' called OpioidNaive
include ChronicPainDecisionPoints version '0.1.0' called ChronicPain

/*
**
**  Recommendation #1
**    Nonpharmacologic therapy and nonopioid pharmacologic therapy are preferred
**    for chronic pain. Clinicians should consider opioid therapy only if expected
**    benefits for both pain and function are anticipated to outweigh risks to the
**    patient. If opioids are used, they should be combined with nonpharmacologic
**    therapy and nonopioid pharmacologic therapy, as appropriate
**    (recommendation category: A, evidence type: 3).
**
** TODO: Include functional description
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds-r4/PlanDefinition-opioidcds-01.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<FHIR.MedicationRequest>

context Patient

define "Trigger Event Prescriptions":
  ( Common."Is Ambulatory Medication Request?"( ContextPrescriptions ) ) Trigger
    where ChronicPain."Chronic Pain Prescription"( Trigger )

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "Is Recommendation Applicable":
  "Inclusion Criteria"
    and not "Exclusion Criteria"

define "Inclusion Criteria":
  // TODO: Rename to "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential"
  "Validate Trigger Event"
  // TODO: Don't reference Exclusion Criteria in Inclusion Criteria
    and not ( "Exclusion Criteria" )
    // TODO: Put all common logic in a common library so this can be:
    // Routines."Opioid Review Useful"
    and OpioidReviewUseful."Opioid Review Would Be Useful"
    // Routines."Is Opioid Naive"
    and OpioidNaive."Is Opioid Naive"

define "Exclusion Criteria":
  false // none

define "Get Indicator":
  if "Is Recommendation Applicable"
    then 'warning'
  else null

define "Get Summary":
  if "Is Recommendation Applicable"
    // NOTE: Wordsmithing here
    then 'Recommend use of nonpharmacologic therapy and nonopioid pharmacologic therapy as alternative'
  else null

define "Get Detail":
  if "Is Recommendation Applicable"
    then 'Medication requests(s): ' + Combine( flatten( Common.GetMedicationNames( "Trigger Event Prescriptions" ) ), ', ' )
  else null
