library OpioidCDS_R4_OpioidReviewUseful version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common_Config version '0.1.0' called Config
include OpioidCDS_R4_Common version '0.1.0' called Common
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

define "Palliative Care Lookback Period":
  Interval[Today() - 90 days, Today()]

define "Opioid Review Would Be Useful":
    if IsTrue(
      "Patient Age Less Than 18"
        or "Order For Palliative Care In Past 90 Days"
        or "Conditions Indicating End Of Life Present"
      )
    then false
    else IsFalse("Conditions Including Cancer To Exclude Opioid Management Indicating End-Stage Disease Present")

/* Needs Config*/
define "Patient Age Less Than 18":
  AgeInYearsAt(Today()) < 18

define "Order For Palliative Care In Past 90 Days":
  [Procedure: Common."Therapies Indicating End of Life Care"] EOLP
    where EOLP.status in { 'in-progress', 'completed', 'preparation'}
    and FHIRHelpers.ToDateTime(EOLP.performed as dateTime) during day of "Palliative Care Lookback Period"

/*NOT SURE IF THIS SHOULD BE MEDICATIONREQUEST OR PROCEDURE RESOURCE
/* define "Order For Palliative Care In Past 90 Days":
  [MedicationRequest: Common."Therapies Indicating End of Life Care"] MR
    where MR.status in { 'active', 'completed'}
      and MR.intent =! null
        and MR.authoredOn during day of "Palliative Care Lookback Period" */

define "Conditions Indicating End Of Life Present":
  [Condition: Common."Limited Life Expectancy Conditions"] LLEC
    //where LLEC.clinicalStatus ~ 'active'
    where exists (
      LLEC.clinicalStatus.coding Coding
        where Coding.code ~ 'active'
    )
/*"Conditions Including Cancer..." sliddeck describes valuesets as including cancer, not sure if that means additional valuesets possibly not indicated in the Opioid Terminology Sheet*/

/*Needs Config*/
define "Conditions Including Cancer To Exclude Opioid Management Indicating End-Stage Disease Present":
  exists ([Condition: Common."End of Life Conditions"] EOLC
    //where EOLC.clinicalStatus ~ 'active'
    where exists (
      EOLC.clinicalStatus.coding Coding
        where Coding.code ~ 'active'
    )
  )
