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
