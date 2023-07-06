library OpioidCDSREC10Common version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSRoutines version '2022.1.0' called Routines
include OpioidCDSCommonConfig version '2022.1.0' called Config

context Patient

define "Lookback Year":
  Interval[Today() - 12 months - 1 days, Today()]

define "Medications Prescribed Within Past Year":
  if Config."Can the implementing EHR support queries for past medications by date range?" 
    then
      (Common."Get MedicationRequest Medication as Code"([MedicationRequest])) MR
        where date from MR.authoredOn during "Lookback Year"
  else
    List<FHIR.MedicationRequest>{}

define "Applicable Because of Unexpected Results":
  HasPositiveScreeningInLast12Months("Alcohol Screenings", true)
    or HasPositiveScreeningInLast12Months("Cocaine Screenings", true)
    or HasPositiveScreeningInLast12Months("PCP Screenings", true)
    or HasPositiveScreeningInLast12Months("Cannabinoid Screenings", true)
    or HasPositiveScreeningInLast12Months("Nonopioid Screenings", true)
    // TODO: Ensure the following are unexpected 
    //   - meaning the patient wasn't prescribed a medication with these ingredients before the lab took place
    or HasPositiveScreeningInLast12Months("Opiate Screenings", Config."Opiate Urine Screening Check Enabled")
    or HasPositiveScreeningInLast12Months("Synthetic Opioid Screenings", Config."Opiate Urine Screening Check Enabled")
    or HasPositiveScreeningInLast12Months("Fentanyl Screenings", Config."Opiate Urine Screening Check Enabled")
    or HasPositiveScreeningInLast12Months("Amphetamine Screenings", true)
    or HasPositiveScreeningInLast12Months("Methadone Screenings", true)

define "Inclusion Criteria":
  Routines."Is Opioid Review Useful?"
  and (not "Patient had Urine Screening in Last 12 Months")

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "Patient had Urine Screening in Last 12 Months":
  (
    exists    ( "Nonopioid Screenings" )
    or exists ( "Cocaine Screenings" )
    or exists ( "PCP Screenings" )
    or exists ( "Amphetamine Screenings" )
    or exists ( "Cannabinoid Screenings" )
    or exists ( "Alcohol Screenings" )
    or exists ( "Methadone Screenings" )
  )
  or
    if Config."Opiate Urine Screening Check Enabled" 
      then (
        exists    ( "Opiate Screenings" )
        or exists ( "Synthetic Opioid Screenings" )
        or exists ( "Fentanyl Screenings" )
      )
    else
      false

define "Laboratory Observations":
  [Observation: "category" in Common."Observation Category Laboratory"]

define "Nonopioid Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Nonopioid Urine Tests")
  )

define "Opiate Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Opioid Urine Tests")
  )

define "Cocaine Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Cocaine Urine Tests")
  )

define "PCP Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."PCP Urine Tests")
  )

define "Synthetic Opioid Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Synthetic Opioid Urine Tests")
  )

define "Fentanyl Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Fentanyl Urine Tests")
  )

define "Amphetamine Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Amphetamine Urine Tests")
  )

define "Cannabinoid Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Cannabinoid Urine Tests")
  )

define "Alcohol Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Alcohol Urine Tests")
  )

define "Methadone Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
    where (LabObservations.code in Common."Methadone Urine Tests")
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

define function GetPositiveScreenings(Screenings List<FHIR.Observation>):
  Screenings Screen where StartsWith(Lower(Screen.value as FHIR.string), 'pos')

define function GetNegativeScreenings(Screenings List<FHIR.Observation>):
  Screenings Screen where StartsWith(Lower(Screen.value as FHIR.string), 'neg')

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

define function GetNegativeScreeningsCount(Screenings List<FHIR.Observation>):
  Count(
    (GetNegativeScreenings(Screenings)) N
      where DateTimeText(N.effective) > DateTimeText("MostRecent"(GetPositiveScreenings(Screenings)).effective)
  )

define function GetPositiveDates(Screenings List<FHIR.Observation>):
  (GetPositiveScreenings(Screenings)) PositiveScreenings
    return DateTimeText(PositiveScreenings.effective)

define function HasPositiveScreeningInLast12Months(Screenings List<FHIR.Observation>, Enabled Boolean):
  if Enabled
    then exists(Screenings Screen where StartsWith(Lower(Screen.value as FHIR.string), 'pos'))
  else false

define function "Get Detail" (isScreeningRecommended Boolean):
  if isScreeningRecommended
    then 'Consider the Benefits and Risks of Conducting a Urine Toxicology Screen'
  else if "Applicable Because of Unexpected Results" 
    then 'Patient may have unexpected urine toxicology test results in the past year, including:'
      & GetUnexpectedResultsReport("Cocaine Screenings", 'Cocaine')
      & GetUnexpectedResultsReport("Opiate Screenings", 'Opiates')
      & GetUnexpectedResultsReport("PCP Screenings", 'PCP')
      & GetUnexpectedResultsReport("Fentanyl Screenings", 'Fentanyl')
      & GetUnexpectedResultsReport("Alcohol Screenings", 'Alcohol')
      & GetUnexpectedResultsReport("Amphetamine Screenings", 'Amphetamines')
      & GetUnexpectedResultsReport("Cannabinoid Screenings", 'Cannabinoids')
      & GetUnexpectedResultsReport("Synthetic Opioid Screenings", 'Synthetic Opioids')
      & GetUnexpectedResultsReport("Methadone Screenings", 'Methadone')
      & '<br /><br />Note: Positive results may be false positives or could indicate the patient is an occasional user or addicted to the substance. For a review regarding interpreting possible false positive urine toxicology results, see https://pubmed.ncbi.nlm.nih.gov/24986836/. It is unknown if the findings reported in this article can be extrapolated to other laboratory analyzers that were not used in the referenced studies. For guidance regarding evaluating and addressing unexpected toxicology test results, see [Recommendation 10 of the 2022 CDC Clinical Practice Guideline](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#Recommendation10).'
  else
      null

define function "Get Summary" (isScreeningRecommended Boolean):
  if isScreeningRecommended
    then 'Consider the benefits and risks of toxicology testing to assess for prescribed medications as well as other prescribed and nonprescribed controlled substances.'
  else if "Applicable Because of Unexpected Results" 
    then 'Patient May Have Unexpected Toxicology Test Results'
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

define function GetUnexpectedResultsReport(Screenings List<FHIR.Observation>, Type String):
  if Length(Screenings) = 0 then null
  else if GetNegativeScreeningsCount(Screenings) > 0 
    then '<br />*Positive for ' + Type + ': ' +
      Combine(GetPositiveDates(Screenings), ', ') +
      '  (' + ToString(GetNegativeScreeningsCount(Screenings)) +
      ' negative since)'   
  else if exists GetPositiveScreenings(Screenings)
    then '<br />*Positive for ' + Type + ': ' +
    Combine(GetPositiveDates(Screenings), ', ')
  else null