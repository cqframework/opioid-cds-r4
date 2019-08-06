library OpioidCDS_R4_OpioidReviewUseful version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common_Config version '0.1.0' called Config
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_ActiveCancerTreatment version '0.1.0' called ActiveCancerTreatment
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
        or "Conditions Indicating End Of Life Present"
        or "Opioid Agents Used for End of Life Treatment Present"
        or "Order For Palliative Care In Past 90 Days"
        or ActiveCancerTreatment."Active Cancer Treatment"
        or "Conditions Including Cancer To Exclude Opioid Management Indicating End-Stage Disease Present"
      )
    then false
    else true

/* Needs Config*/
define "Patient Age Less Than 18":
  Config."Age Less than 18 Years Is Enabled"
    and AgeInYearsAt(Today()) < 18

define "Conditions Indicating End Of Life Present":
  exists (
    [Condition: Common."Limited Life Expectancy Conditions"] LLEC
      where exists (
        LLEC.clinicalStatus.coding Coding
          where Coding.code in Common."Active Condition"
      )
  )

define "Opioid Agents Used for End of Life Treatment Present":
  Config."Opioid Agents Used for End of Life Treatment Present Is Enabled"
    and exists (Common."Medications Indicating End of Life")

define "Order For Palliative Care In Past 90 Days":
  exists (
    [ServiceRequest: Common."Therapies Indicating End of Life Care"] SR
      where SR.status in { 'active', 'completed'}
        and SR.intent =! null
        and FHIRHelpers.ToDateTime(SR.authoredOn) during day of "Palliative Care Lookback Period"
  )

/*"Conditions Including Cancer..." slidedeck describes valuesets as including cancer, not sure if that means additional valuesets possibly not indicated in the Opioid Terminology Sheet*/
define "Conditions Including Cancer To Exclude Opioid Management Indicating End-Stage Disease Present":
  Config."Conditions Including Cancer to Exclude Opioid Management Indicating End-Stage Disease Present Is Enabled"
    and exists (
      [Condition: Common."End of Life Conditions"] EOLC
        where exists (
          EOLC.clinicalStatus.coding Coding
            where Coding.code in Common."Active Condition"
        )
    )
