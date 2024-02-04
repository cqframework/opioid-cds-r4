library OpioidCDSREC10Common version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSRoutines version '2022.1.0' called Routines
include OpioidCDSCommonConfig version '2022.1.0' called Config

context Patient

define "Lookback Year":
  Interval[Today() - 12 months - 1 days, Today()]

define "Lookback Year Excluding Today":
  Interval[Today() - 12 months - 1 day, Today() - 1 day]

define "Applicable Because of Unexpected Results":
  HasPositiveScreeningInLast12Months("Cocaine Screenings", true)
    or HasPositiveScreeningInLast12Months("PCP Screenings", true)
    or HasPositiveScreeningInLast12Months("Cannabinoid Screenings", true)
    or (
      HasPositiveScreeningInLast12Months("Opiate Screenings", Config."Opiate Urine Screening Check Enabled")
      and not "Has Active Prescription for Opiate?"
    )
    or (
      HasPositiveScreeningInLast12Months("Synthetic Opioid Screenings", Config."Opiate Urine Screening Check Enabled")
      and not "Has Active Prescription for Synthetic Opioid?"
    )
    or (
      HasPositiveScreeningInLast12Months("Fentanyl Screenings", Config."Opiate Urine Screening Check Enabled")
      and not "Has Active Prescription for Fentanyl?"
    )
    or (
      HasPositiveScreeningInLast12Months("Amphetamine Screenings", true)
      and not "Has Active Prescription for Amphetamine?"
    )
    or (
      HasPositiveScreeningInLast12Months("Methadone Screenings", true)
      and not "Has Active Prescription for Methadone?"
    )

define "Inclusion Criteria":
  Routines."Is Opioid Review Useful?"
  and (not "Patient had Urine Screening in Last 12 Months")

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "Patient had Urine Screening in Last 12 Months":
  exists ("All Opioid or Non-opioid Screenings in Past Year")

define "All Opioid or Non-opioid Screenings in Past Year":
  [Observation: Common."All Drug Urine Screening"] AllLabs
    where AllLabs.category in Common."Observation Category Laboratory"
      and date from AllLabs.effective in day of "Lookback Year"
      and not ( AllLabs.status.value in { 'unknown', 'entered-in-error', 'cancelled' } )

define "Normalize Active Prescriptions":
  Common."Get MedicationRequest Medication as Code"(Common."Active Medication List")

define "Fentanyl Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."Fentanyl Urine Tests"

define "Has Active Prescription for Fentanyl?":
  exists (
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Fentanyl Medications"
  )

define "Amphetamine Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."Amphetamine Urine Tests"

define "Has Active Prescription for Amphetamine?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Amphetamine Medications"
  )

define "Methadone Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."Methadone Urine Tests"

define "Has Active Prescription for Methadone?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Methadone Medications"
  )

define "Opiate Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."Opiate Urine Tests"

define "Has Active Prescription for Opiate?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Opiate Medications"
  )

define "Synthetic Opioid Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."Synthetic Opioid Urine Tests"

define "Has Active Prescription for Synthetic Opioid?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Synthetic Opioid Medications"
  )

define "Cocaine Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."Cocaine Urine Tests"

define "PCP Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."PCP Urine Tests"

define "Cannabinoid Screenings":
  "All Opioid or Non-opioid Screenings in Past Year" AllLabs
    where AllLabs.code in Common."Cannabinoid Urine Tests"

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

define function GetUnexpectedResultsReport(Screenings List<FHIR.Observation>, Type String):
  if Length(Screenings) = 0 then null
  else if exists GetPositiveScreenings(Screenings)
    then '<br />*Positive for ' + Type + ': ' +
    Combine(GetPositiveDates(Screenings), ', ') +
      (
        if GetNegativeScreeningsCount(Screenings) > 0
          then '  (' + ToString(GetNegativeScreeningsCount(Screenings)) +
          ' negative since)'
        else ''
      )
  else null

define "Positive Dates List":
  distinct ("Positive Screenings List" Screenings
    return Screenings.date)

define "Positive Screenings List":
  (
    (
    "Cocaine Screenings" CocaineScreening
      where StartsWith(Lower(CocaineScreening.value as FHIR.string), 'pos')
      return {
        ingredient: 'Cocaine',
        date: date from FHIRHelpers.ToDateTime(CocaineScreening.effective as FHIR.dateTime)
      }
    ) union (
      "PCP Screenings" PCPScreening
        where StartsWith(Lower(PCPScreening.value as FHIR.string), 'pos')
        return {
          ingredient: 'PCP',
          date: date from FHIRHelpers.ToDateTime(PCPScreening.effective as FHIR.dateTime)
        }
    ) union (
      "Cannabinoid Screenings" THCScreening
        where StartsWith(Lower(THCScreening.value as FHIR.string), 'pos')
        return {
          ingredient: 'Cannabinoid',
          date: date from FHIRHelpers.ToDateTime(THCScreening.effective as FHIR.dateTime)
        }
    ) union (
      if Config."Opiate Urine Screening Check Enabled" 
        then (
          "Opiate Screenings" OpiateScreening
            where StartsWith(Lower(OpiateScreening.value as FHIR.string), 'pos')
            return {
              ingredient: 'Opiate',
              date: date from FHIRHelpers.ToDateTime(OpiateScreening.effective as FHIR.dateTime)
            }
        )
      else null
    ) union (
      if Config."Opiate Urine Screening Check Enabled" 
        then (
          "Synthetic Opioid Screenings" SyntheticOpioidScreening
            where StartsWith(Lower(SyntheticOpioidScreening.value as FHIR.string), 'pos')
            return {
              ingredient: 'Synthetic Opioid',
              date: date from FHIRHelpers.ToDateTime(SyntheticOpioidScreening.effective as FHIR.dateTime)
            }
        )
      else null
    ) union (
      if Config."Opiate Urine Screening Check Enabled" 
        then (
          "Fentanyl Screenings" FentanylScreening
            where StartsWith(Lower(FentanylScreening.value as FHIR.string), 'pos')
            return {
              ingredient: 'Fentanyl',
              date: date from FHIRHelpers.ToDateTime(FentanylScreening.effective as FHIR.dateTime)
            }
        )
      else null
    ) union (
      "Amphetamine Screenings" AmphetamineScreening
        where StartsWith(Lower(AmphetamineScreening.value as FHIR.string), 'pos')
        return {
          ingredient: 'Amphetamine',
          date: date from FHIRHelpers.ToDateTime(AmphetamineScreening.effective as FHIR.dateTime)
        }
    ) union (
      "Methadone Screenings" MethadoneScreening
        where StartsWith(Lower(MethadoneScreening.value as FHIR.string), 'pos')
        return {
          ingredient: 'Methadone',
          date: date from FHIRHelpers.ToDateTime(MethadoneScreening.effective as FHIR.dateTime)
        }
    )
  ) X sort by date
  
define "Get Unexpected Details Table":
  Common."Style Header" + "Unexpected Div Start" + "Table Start" + Combine("Table Columns") + "Table Row End" + Combine("Unexpected Rows") + "Table End" + "Details More Info" + "Unexpected Div End"

define "Unexpected Rows":
  "Positive Screenings List" Screenings
    return (
      "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End"
      + (
        (IndexOf("Positive Dates List", Screenings.date)) Idx 
          return (
            if Idx = -1
              then "Table Cell Normal Start" + 'neg' + "Table Cell End"
            else "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
          )
      ) + "Table Row End"
    )
    
define "Table Cell End":
  '<\/td>'

define "Table Cell Unexpected Start":
  '<td class=\"details-table-cell-unexpected\">'

define "Table Cell Normal Start":
  '<td class=\"details-table-cell\">'

define "Table Row Start":
  '<tr>'

define "Table Row End":
  '<\/tr>'

define "Table Columns":
  "Positive Dates List" Dates
    return '<th class=\"details-table-header\">' + ToString(Dates) + '<\/th>'

define "Unexpected Div Start":
  '<div class=\"alert-body\"><div><p>Patient may have <strong>unexpected urine toxicology test results<\/strong> in the past year, including:<\/p><\/div>'
define "Unexpected Div End":
  '</div>'

define "Table Start":
  '<div><table class=\"details-table\"><caption class=\"details-caption\">Urine Toxicology Results<\/caption><tr><th class=\"details-table-header\">Substance<\/th>'

define "Table End":
  '<\/table><\/div>'

define "Details More Info":
  '<div class=\"more-text\">Note on false positives<details class=\"details-details\"><summary class=\"details-summary\"><\/summary><br\/><br\/>Positive results may be a false positives or could represent occasional use or possible substance use disorder.<br\/><br\/>For a review regarding interpreting possible false positive urine toxicology results, see <a target=\"_blank\" href=\"https:\/\/pubmed.ncbi.nlm.nih.gov\/24986836\">http:\/\/pubmed.ncbi.nlm.nih.gov\/24986836<\/a>. It is unknown if the findings reported in this article can be extrapolated to other laboratory analyzers that were not used in the referenced studies.<br\/><br\/>For guidance regarding evaluating and addressing unexpected toxicology tests results, see <a target=\"_blank\" href=\"https:\/\/www.cdc.gov\/mmwr\/volumes\/71\/rr\/rr7103a1.htm#Recommendation10\">Recommendation 10 of the 22 CDC Clinical Practice Guideiline<\/a>.<\/details><\/div>'