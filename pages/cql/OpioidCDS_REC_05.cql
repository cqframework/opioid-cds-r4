library OpioidCDS_REC_05 version '0.1.0'

using FHIR version '4.0.0'

include OpioidCDS_Common version '0.1.0' called Common
include ChronicPainDecisionPoints version '0.1.0' called ChronicPain

/*
**
** Recommendation #5
** NOTE: Add recommendation text here
** NOTE: Update functional description, it discusses chronic pain and opioid 80 for 90, should not do that (update based on latest process docs)
** NOTE: Update to use Opioid Review Useful, per latest process docs
*/

/*
  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds-r4/PlanDefinition-opioidcds-05.html
*/

parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Inclusion Criteria":
  AgeInYears() >= 18
    and not "Exclusion Criteria"
    and "Total MME" >= 50 'mg/d'

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "Total MME":
  Common.TotalMME(
    (ContextPrescriptions union Common."Active Ambulatory Opioid Rx") TriggerScript
      where ChronicPain."Chronic Pain Prescription"( TriggerScript )
  )

define "Taper Now": "Total MME".value >= 90

define "Consider Tapering": "Total MME".value < 90

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then
      'High risk for opioid overdose - '
        + case when "Taper Now"
           then 'taper now'
           else 'consider tapering'
         end
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then'Total morphine milligram equivalent (MME) is ' + ToString("Total MME") + '. Taper to less than 50.'
  else null
