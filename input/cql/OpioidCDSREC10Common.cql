library OpioidCDSREC10Common version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSRoutines version '2022.1.0' called Routines
include OpioidCDSCommonConfig version '2022.1.0' called Config

context Patient

define "Lookback Year":
  Interval[Today() - 12 months - 1 days, Today() - 1 day]

define "Applicable Because of Positive Cocaine or PCP or Opiates":
  if exists (Common."Opioid Other Than Synthetic Ordered In Last 12 Months") then
    "Has Positive Screening for Cocaine in Last 12 Months"
    or "Has Positive Screening for PCP in Last 12 Months"
  else
    "Has Positive Screening for Cocaine in Last 12 Months"
      or "Has Positive Screening for PCP in Last 12 Months"
      or
        if Config."Opiate Urine Screening Check Enabled" then
          "Has Positive Screening for Opiates in Last 12 Months"
        else false

define "Inclusion Criteria":
  Routines."Is Opioid Review Useful?"
  and (not "Patient had Urine Screening in Last 12 Months")

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "Patient had Urine Screening in Last 12 Months":
  (
    exists ("Non-opioid Screenings")
    or exists ("Cocaine Screenings")
    or exists ("PCP Screenings")
  )
  or
    if Config."Opiate Urine Screening Check Enabled" then
      exists ("Opiate Screenings")
    else
      false

define "Laboratory Observations":
  [Observation: "category" in Common."Observation Category Laboratory"]

define "Non-opioid Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Non-opioid drug urine screening")
  )

define "Opiate Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Opioid drug urine screening")
  )

define "Cocaine Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Cocaine Urine Tests")
  )

define "PCP Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."PCP Urine Tests")
  )

define function "GetRelevantScreenings" (obsList List<Observation>):
  obsList LabObservations
     where date from LabObservations.effective in day of "Lookback Year"
       and not (LabObservations.status.value in { 'unknown', 'entered-in-error', 'cancelled' })

// Returns a text representation of a dateTime using the CQL `ToString` function.
// @param d - a FHIR dateTime to get text for
// @returns {System.String} the text representation of the dateTime
define function "DateTimeText" (d FHIR.dateTime):
  ToString(d.value)

define "Positive Opiate Screenings":
  "Opiate Screenings" Opiate where StartsWith(Lower(Opiate.value as FHIR.string), 'pos')

define "Negative Opiate Screenings":
  "Opiate Screenings" Opiate where StartsWith(Lower(Opiate.value as FHIR.string), 'neg')

define "Positive PCP Screenings":
  "PCP Screenings" PCP where StartsWith(Lower(PCP.value as FHIR.string), 'pos')

define "Negative PCP Screenings":
  "PCP Screenings" PCP where StartsWith(Lower(PCP.value as FHIR.string), 'neg')

define "Positive Cocaine Screenings":
  "Cocaine Screenings" Cocaine where StartsWith(Lower(Cocaine.value as FHIR.string), 'pos')

define "Negative Cocaine Screenings":
  "Cocaine Screenings" Cocaine where StartsWith(Lower(Cocaine.value as FHIR.string), 'neg')

/*
  borrowed from CDS4CPM CDS_Connect_Commons_for_FHIRv400
  Should this go into OpioidCDSCommon?
*/
define function "MostRecent" (ObsList List<Observation>):
  Last(ObsList O sort by Coalesce(
    (effective as FHIR.dateTime).value,
    (effective as FHIR.Period)."end".value,
    (effective as FHIR.Period)."start".value,
    issued.value)
  )

define "Negative PCP Screenings Count Since Last Positive Screening":
  Count(
    "Negative PCP Screenings" N
      where DateTimeText(N.effective) > DateTimeText("MostRecent"("Positive PCP Screenings").effective)
  )

define "Negative Opiate Screenings Count Since Last Positive Screening":
  Count(
    "Negative Opiate Screenings" N
      where DateTimeText(N.effective) > DateTimeText("MostRecent"("Positive Opiate Screenings").effective)
  )

define "Negative Cocaine Screenings Count Since Last Positive Screening":
  Count(
    "Negative Cocaine Screenings" N
      where DateTimeText(N.effective) > DateTimeText("MostRecent"("Positive Cocaine Screenings").effective)
  )

define "Positive Opiate Dates in Lookback Period":
  "Positive Opiate Screenings" Opiate
    return DateTimeText(Opiate.effective)

define "Positive Cocaine Dates in Lookback Period":
  "Positive Cocaine Screenings" CS
    return DateTimeText(CS.effective)

define "Positive PCP Dates in Lookback Period":
  "Positive PCP Screenings" PS
    return DateTimeText(PS.effective)

define "Has Positive Screening for Cocaine in Last 12 Months":
  exists ("Cocaine Screenings" CS where StartsWith(Lower(CS.value as FHIR.string), 'pos'))

define "Has Positive Screening for PCP in Last 12 Months":
  exists ("PCP Screenings" PCP where StartsWith(Lower(PCP.value as FHIR.string), 'pos'))

define "Has Positive Screening for Opiates in Last 12 Months":
  if Config."Opiate Urine Screening Check Enabled" then
    exists ("Opiate Screenings" Opioid where StartsWith(Lower(Opioid.value as FHIR.string), 'pos'))
  else false

define "Cocaine Detail":
  if "Has Positive Screening for Cocaine in Last 12 Months" then
    "Cocaine Summary"
  else null

define "Opiates Detail":
  if "Has Positive Screening for Opiates in Last 12 Months" then
    "Opiates Summary"
  else null

define "PCP Detail":
  if "Has Positive Screening for PCP in Last 12 Months" then
    "PCP Summary"
  else null

define function "Get Detail" (isScreeningRecommended Boolean):
  if isScreeningRecommended then
    'Patients on opioid therapy should have a urine drug test performed every 12 months. Consult [2022 CDC Clinical Practice Guideline Recommendation 10](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=evidence%20type%3A%204).-,Implementation%20Considerations,-Toxicology%20testing%20should) for more guidance regarding toxicology testing.'
  else if "Applicable Because of Positive Cocaine or PCP or Opiates" then
    'Patient may have unexpected urine toxicology test results in the past year, including:<br/>'
    & "Cocaine Detail"
    & "Opiates Detail"
    & "PCP Detail"
    & '<br/>Note: Positive results may be false positives or could indicate the patient is an occasional user or addicted to the substance. For a review regarding interpreting possible false positive urine toxicology results, see https://pubmed.ncbi.nlm.nih.gov/24986836/. It is unknown if the findings reported in this article can be extrapolated to other laboratory analyzers that were not used in the referenced studies. Consult [2022 CDC Clinical Practice Guideline Recommendation 10](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=evidence%20type%3A%204).-,Implementation%20Considerations,-Toxicology%20testing%20should) for more guidance regarding toxicology testing.'
  else
      null

define "Indicator":
  'warning'

    /*
        Used only in PlanDefinition
     */
define function "Get Summary" (isScreeningRecommended Boolean):
  if isScreeningRecommended then
    'Patient May Have Unexpected Toxicology Test Results'
  else if "Applicable Because of Positive Cocaine or PCP or Opiates" then
    if Config."Opiate Urine Screening Check Enabled" then
      'Positive Cocaine or PCP or Opiates in Urine Screening'
    else 'Positive Cocaine or PCP in Urine Screening'
  else null

define "Urine Drug Screening ProcedureRequest Category":
  FHIR.CodeableConcept {
    coding: {
      FHIR.Coding {
        system: FHIR.uri { value: 'http://terminology.hl7.org/CodeSystem/medicationrequest-category' },
        code: FHIR.code { value: 'outpatient' },
        display: FHIR.string { value: 'Outpatient' }
      }
    }
  }
  /* singleton from (First(
    [Encounter] E
      where E.period starts same day as Today()
      sort by start of period desc
  ).type) */

define "Cocaine And PCP Summary":
  'Positive for Cocaine AND PCP <br/><br/>' +
    "Cocaine Summary" + '<br/>' + "PCP Summary"

define "Opiates Summary":
  if not exists Common."Opioid Other Than Synthetic Ordered In Last 12 Months" then
    if "Negative Opiate Screenings Count Since Last Positive Screening" > 0 then
      '<br/>*Positive for Opiates: ' +
      Combine("Positive Opiate Dates in Lookback Period", ', ') +
      '  (' + ToString("Negative Opiate Screenings Count Since Last Positive Screening") +
      ' negative since)'
    else
      '<br/>*Positive for Opiates: ' +
      Combine("Positive Opiate Dates in Lookback Period", ', ')
  else null

define "PCP Summary":
  if "Negative PCP Screenings Count Since Last Positive Screening" > 0 then
    '<br/>*Positive for PCP: <br/>' +
    Combine("Positive PCP Dates in Lookback Period", ', ') +
    '  (' + ToString("Negative PCP Screenings Count Since Last Positive Screening") +
    ' negative since)'
  else
    '<br/>*Positive for PCP: <br/>' +
    Combine("Positive PCP Dates in Lookback Period", ', ')

define "Cocaine Summary":
  if "Negative Cocaine Screenings Count Since Last Positive Screening" > 0 then
    '<br/>*Positive for Cocaine: <br/>' +
    Combine("Positive Cocaine Dates in Lookback Period", ', ') +
    '  (' + ToString("Negative Cocaine Screenings Count Since Last Positive Screening") +
    ' negative since)'
  else
    '<br/>*Positive for Cocaine: <br/>' +
    Combine("Positive Cocaine Dates in Lookback Period", ', ')
