library OpioidCDS_R4_OpioidNaive version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common_Config version '0.1.0' called Config

/*
**
**  Opioid Naive subroutine
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-opioidnaive.html
*/


context Patient

/*
    Opioid with ambulatory care abuse potential prescription found in past 90 days including today
    Opioid with ambulatory care abuse potential reported in past 90 days
    Opioid with ambulatory care abuse potential dispensing event found in past 90 days including today
*/
