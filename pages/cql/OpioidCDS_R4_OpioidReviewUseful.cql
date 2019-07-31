library OpioidCDS_R4_OpioidReviewUseful version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common_Config version '0.1.0' called Config

/*
**
**  Opioid Review Useful subroutine
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-opioidreviewuseful.html
*/


context Patient
