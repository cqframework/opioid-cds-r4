library OpioidCDS_R4_REC_01 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful
include OpioidCDS_R4_OpioidNaive version '0.1.0' called OpioidNaive

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
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds-r4/PlanDefinition-opioidcds-01.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<FHIR.MedicationRequest>

context Patient

define "Trigger Event Prescriptions":
  Common."Is Ambulatory Medication Request?"(ContextPrescriptions)

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "Inclusion Criteria":
  "Validate Trigger Event"
    and not ("Exclusion Criteria")
    and OpioidReviewUseful."Opioid Review Would Be Useful"
    and OpioidNaive."Is Opioid Naive"

define "Exclusion Criteria":
  false // none

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'Recommend use of nonpharmacologic therapy and nonopioid pharmacologic therapy as alternative'
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then 'Medication requests(s): ' + Combine(Common.GetMedicationNames("Trigger Event Prescriptions"), ', ')
  else null
