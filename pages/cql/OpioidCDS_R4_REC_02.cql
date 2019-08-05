library OpioidCDS_R4_REC_02 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_Common_Config version '0.1.0' called Config
//include OpioidCDS_R4_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful
include OpioidCDS_R4_OpioidNaive version '0.1.0' called OpioidNaive

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
	http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-02.html
*/

// Trigger Event Rx
parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Trigger Event Prescriptions":
  ContextPrescriptions triggerScripts
      where true //TODO

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "Inclusion Criteria":
  AgeInYears() >= 18
    and "Validate Trigger Event"
    and not "Exclusion Criteria"

define "Exclusion Criteria":
  false

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'blah'
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then 'blah'
  else null
