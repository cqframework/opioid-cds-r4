library OpioidCDS_R4_REC_09 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_Common_Config version '0.1.0' called Config
include OpioidCDS_R4_OpioidReviewUseful version '0.1.0' called OpioidReviewUseful

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
	http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-09.html
*/


context Patient

define "Inclusion Criteria":
  true

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
