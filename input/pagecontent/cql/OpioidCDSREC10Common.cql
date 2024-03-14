library OpioidCDSREC10Common version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSRoutines version '2022.1.0' called Routines
include OpioidCDSCommonConfig version '2022.1.0' called Config

context Patient

// Constants

define "Lookback Year":
  Interval[Today() - 12 months - 1 days, Today()]

define "Amphetamine Simple Identifier": 'Amphetamine'
define "Cannabinoid Simple Identifier": 'Cannabinoid'
define "Cocaine Simple Identifier": 'Cocaine'
define "Fentanyl Simple Identifier": 'Fentanyl'
define "Methadone Simple Identifier": 'Methadone'
define "Opiate Simple Identifier": 'Opiate'
define "Opioid Simple Identifier": 'Opioid'
define "PCP Simple Identifier": 'Phencyclidine (PCP)'
define "Synthetic Opioid Simple Identifier": 'Synthetic Opioid'

define "Opioid Ingredient List": {
  "Fentanyl Simple Identifier", "Opiate Simple Identifier",
  "Opioid Simple Identifier", "Synthetic Opioid Simple Identifier"
}

define "Ingredient List": "Opioid Ingredient List" union {
  "Amphetamine Simple Identifier", "Cannabinoid Simple Identifier",
  "Cocaine Simple Identifier", "Methadone Simple Identifier",
  "PCP Simple Identifier"
}

// Criteria Expressions
// Scenarios:
//   - Warning to conduct a UDS
//   - Warning that unexpected results were found in UDS results
//     - 3 flavors: 
//       - Positive results for possible illicit drug use (i.e. Cocaine, PCP, Xylazine, and Cannabinoids)
//       - Positive results for possible unprescribed Opioids and Amphetamines
//       - Negative results for prescribed Opioids (diversion)

/*
@description: Determines whether an opioid review is appropriate for the patient and whether they had a UDS performed in the past year
*/
define "Inclusion Criteria":
  Routines."Is Opioid Review Useful?"
    and not exists ("All Opioid or Non-opioid Screenings in Past Year")

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "All Opioid or Non-opioid Screenings in Past Year":
  (
    [Observation: Common."All Drug Urine Screening"] Lab
      where date from Lab.effective in day of "Lookback Year"
        and not (Lab.status.value in { 'unknown', 'entered-in-error', 'cancelled' })
  ) X sort by date from FHIRHelpers.ToDateTime(effective as FHIR.dateTime) desc

/*
@description: Determines whether an opioid review is appropriate for the patient and whether they had a UDS with unexpected results in the past year
*/
define "Inclusion Criteria For Unexpected Results":
  Routines."Is Opioid Review Useful?"
    and (
      exists "Cocaine Screenings"
        or exists "PCP Screenings"
        or exists "Cannabinoid Screenings"
        or (
          exists "Opiate Screenings"
            and not "Has Active Prescription for Opiate?"
        )
        or (
          exists "Synthetic Opioid Screenings"
            and not "Has Active Prescription for Synthetic Opioid?"
        )
        or (
          exists "Fentanyl Screenings"
            and not "Has Active Prescription for Fentanyl?"
        )
        or (
          exists "Amphetamine Screenings"
            and not "Has Active Prescription for Amphetamine?"
        )
        or (
          exists "Methadone Screenings"
            and not "Has Active Prescription for Methadone?"
        )
        or "Unexpected Negative Results On Latest UDS"
    )

/*
@description: Determines whether the patient has an active Opioid medication and latest UDS did not include results for Opioid medications.
NOTE: In this context, Opioid medications also include Opiate, Synthetic Opioid and Fentanyl medications
*/
define "Unexpected Negative Results On Latest UDS":
  exists ( "Active Opioid Medications" ) 
    and not (
      (First("All Opioid or Non-opioid Screenings in Past Year")) MostRecentLab
        return AnyTrue({
          (MostRecentLab.code in Common."Opiate Urine Tests"), 
          (MostRecentLab.code in Common."Synthetic Opioid Urine Tests"),
          (MostRecentLab.code in Common."Fentanyl Medications"),
          (MostRecentLab.code in Common."Opioid drug urine screening")
        })
    )

// HTML Details Response

define "Get HTML Details":
  Common."Style Header" + "Unexpected Div Start" + "Unexpected Div Details Text" + "Details More Info" + "Div End"

// Labs and Active Med Expressions

define "Has Active Prescription for Opioid?":
  exists (
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Opioid analgesics with ambulatory misuse potential"
  )

define "Fentanyl Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."Fentanyl Urine Tests", Config."Opiate Urine Screening Check Enabled"
  )

define "Has Active Prescription for Fentanyl?":
  exists (
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Fentanyl Medications"
  )

define "Amphetamine Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."Amphetamine Urine Tests", true
  )

define "Has Active Prescription for Amphetamine?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Amphetamine Medications"
  )

define "Methadone Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."Methadone Urine Tests", true
  )

define "Has Active Prescription for Methadone?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Methadone Medications"
  )

define "Opiate Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."Opiate Urine Tests", Config."Opiate Urine Screening Check Enabled"
  )

define "Has Active Prescription for Opiate?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Opiate Medications"
  )

define "Synthetic Opioid Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."Synthetic Opioid Urine Tests", Config."Opiate Urine Screening Check Enabled"
  )

define "Has Active Prescription for Synthetic Opioid?":
  exists(
    "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Synthetic Opioid Medications"
  )

define "Cocaine Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."Cocaine Urine Tests", true
  )

define "PCP Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."PCP Urine Tests", true
  )

define "Cannabinoid Screenings":
  GetPositiveLabsInPastYear(
    "All Opioid or Non-opioid Screenings in Past Year" AllLabs
      where AllLabs.code in Common."Cannabinoid Urine Tests", true
  )

define "Active Opioid Medications":
  "Normalize Active Prescriptions" ActiveRx
      where ActiveRx.medication in Common."Fentanyl Medications"
        or ActiveRx.medication in Common."Opiate Medications"
        or ActiveRx.medication in Common."Synthetic Opioid Medications"
        or ActiveRx.medication in Common."Opioid analgesics with ambulatory misuse potential"

define "All Positive Labs In Past Year":
  "Amphetamine Screenings" union "Cannabinoid Screenings" union "Cocaine Screenings" 
    union "Fentanyl Screenings" union "Methadone Screenings" union "Opiate Screenings" 
    union "PCP Screenings" union "Synthetic Opioid Screenings"

define "Positive Lab Dates In Past Year":
  (
    "All Positive Labs In Past Year" Lab
      return date from FHIRHelpers.ToDateTime(Lab.effective as FHIR.dateTime)
  ) X sort desc

// Lab Details Structures

// define "Unexpected Negative Details":
//   if "Unexpected Negative Results On Latest UDS"
//     then (
//       (First("All Opioid or Non-opioid Screenings in Past Year")) MostRecentLab
//         return {
//           LabDetailsTuple("Fentanyl Simple Identifier", null), 
//           LabDetailsTuple("Opiate Simple Identifier", null),
//           LabDetailsTuple("Opioid Simple Identifier", null), 
//           LabDetailsTuple("Synthetic Opioid Simple Identifier", null)
//         }
//     )
//   else {}

define "Unexpected Positive Details":
  (
    "Amphetamine Screenings" AmphetamineScreening
      return LabDetailsTuple("Amphetamine Simple Identifier", AmphetamineScreening)
  ) union (
    "Cannabinoid Screenings" CannabinoidScreening
      return LabDetailsTuple("Cannabinoid Simple Identifier", CannabinoidScreening)
  ) union (
    "Cocaine Screenings" CocaineScreening
      return LabDetailsTuple("Cocaine Simple Identifier", CocaineScreening)
  ) union (
    "Fentanyl Screenings" FentanylScreening
      return LabDetailsTuple("Fentanyl Simple Identifier", FentanylScreening)
  ) union (
    "Methadone Screenings" MethadoneScreening
      return LabDetailsTuple("Methadone Simple Identifier", MethadoneScreening)
  ) union (
    "Opiate Screenings" OpiateScreening
      return LabDetailsTuple("Opiate Simple Identifier", OpiateScreening)
  ) union (
    "PCP Screenings" PCPScreening
      return LabDetailsTuple("PCP Simple Identifier", PCPScreening)
  ) union (
    "Synthetic Opioid Screenings" SyntheticOpioidScreening
      return LabDetailsTuple("Synthetic Opioid Simple Identifier", SyntheticOpioidScreening)
  )

define "Lab Details":
  //"Unexpected Negative Details" union 
  "Unexpected Positive Details"

// Details Plain-Text Logic 

define "Unexpected Negative Details Text":
  if "Unexpected Negative Results On Latest UDS"
    then '<p>Negative Lab results for Opioids (possible diversion) on ' + 
      ToString(
        date from FHIRHelpers.ToDateTime((First("All Opioid or Non-opioid Screenings in Past Year")).effective as FHIR.dateTime)
      ) + ' despite the presence of Opioid medications on the active med list<\/p>'
  else ''

define "Unexpected Positive Details Text":
  "Unexpected Positive Details" Details
    return (
      '<p>Positive for ' + Details.ingredient + (
        if Details.detailedIdentifier is not null and Details.detailedIdentifier != '' 
          then '(' + Details.detailedIdentifier + ')' 
        else ''
      ) + ' on ' + ToString(Details.date) + '<\/p>'
    )

define "Details Text":
  "Unexpected Negative Details Text" + Combine("Unexpected Positive Details Text", '\n')

// Details Table Logic
/*
  | Urine Toxicology Results                 | - Title
  -------------------------------------------------------
  | Substance  | Date 1    | Date 2    | ... | - Header
  | SubstanceA | pos^1/neg | pos^2/neg | ... | - Row A
  | SubstanceB | pos^3/neg | pos^4/neg | ... | - Row B
  | ... |
  -------------------------------------------------------
  | 1 - SubstanceA Detailed Identifier       | - Footer
  | 2 - SubstanceB Detailed Identifier       |
  | ... |
*/

define "Details Table": 
  "Table Start" + Combine("Table Headers") + Combine("Unexpected Details Table Rows") + "Table End"

define "Unexpected Details Table Rows":
  "Lab Details" Details
    let Count: IndexOf("Lab Details", Details) + 1
    return '<tr>' + GetExpectedColumn(Details.ingredient) + Combine(ResolveDetailColumns(Count, Details)) + '<\/tr>'

// define "Unexpected Positive Details Table":
//   "Lab Details" Detail
//     let Count: IndexOf("Lab Details", Detail)
//     return (
//       case Detail.ingredient
//         when "Fentanyl Simple Identifier"
//           then if "Unexpected Negative Results On Latest UDS"
//             then GetDetailsTableRow("Fentanyl Simple Identifier", Detail, Count, true)
//           else GetDetailsTableRow("Fentanyl Simple Identifier", Detail, Count, false)
//         when "Opiate Simple Identifier"
//           then if "Unexpected Negative Results On Latest UDS"
//             then GetDetailsTableRow("Opiate Simple Identifier", Detail, Count, true)
//           else GetDetailsTableRow("Opiate Simple Identifier", Detail, Count, false)
//         when "Opioid Simple Identifier"
//           then if "Unexpected Negative Results On Latest UDS"
//             then GetDetailsTableRow("Opioid Simple Identifier", Detail, Count, true)
//           else GetDetailsTableRow("Opioid Simple Identifier", Detail, Count, false)
//         when "Synthetic Opioid Simple Identifier"
//           then if "Unexpected Negative Results On Latest UDS"
//             then GetDetailsTableRow("Synthetic Opioid Simple Identifier", Detail, Count, true)
//           else GetDetailsTableRow("Synthetic Opioid Simple Identifier", Detail, Count, false)
//         when "Amphetamine Simple Identifier"
//           then GetDetailsTableRow("Amphetamine Simple Identifier", Detail, Count, false)
//         when "Cannabinoid Simple Identifier"
//           then GetDetailsTableRow("Cannabinoid Simple Identifier", Detail, Count, false)
//         when "Cocaine Simple Identifier"
//           then GetDetailsTableRow("Cocaine Simple Identifier", Detail, Count, false)
//         when "Methadone Simple Identifier"
//           then GetDetailsTableRow("Methadone Simple Identifier", Detail, Count, false)
//         when "PCP Simple Identifier"
//           then GetDetailsTableRow("PCP Simple Identifier", Detail, Count, false)
//         else ''
//       end
//     )

// Helpers  

define "Normalize Active Prescriptions":
  Common."Get MedicationRequest Medication as Code"(Common."Active Medication List")

define "All Negative":
  "Positive Lab Dates In Past Year" PositiveDate
    return all GetExpectedColumn('neg')

define "Unexpected Div Start":
  '<div class=\"alert-body\"><div><p>Patient may have <strong>unexpected urine toxicology test results<\/strong> in the past year, including:<\/p><\/div>'

define "Div End": '<\/div>'

define "Unexpected Div Details Text": '<div>' + "Details Text" + '<\/div>'

define "Table Start":
  '<div><table class=\"details-table\"><caption class=\"details-caption\">Urine Toxicology Results<\/caption><tr><th class=\"details-table-header\">Substance<\/th>'

define "Table End":
  '<\/table><\/div>'

define "Table Headers":
  "Positive Lab Dates In Past Year" PositiveDate
    return '<th class=\"details-table-header\">' + ToString(PositiveDate) + '<\/th>'

define "Details More Info":
  '<div id=\"box\">\r\n  <p>Note on false positives and tabular data...<\/p>\r\n  <input type=\"checkbox\" class=\"show-more\"> Show more\r\n  <div class=\"more\">\r\n'
     + "Details Table"
     +'<p>Positive results may be a false positives or could represent occasional use or possible substance use disorder.<br\/><br\/>For a review regarding interpreting possible false positive urine toxicology results, see <a target=\"_blank\" href=\"https:\/\/pubmed.ncbi.nlm.nih.gov\/24986836\">http:\/\/pubmed.ncbi.nlm.nih.gov\/24986836<\/a>. It is unknown if the findings reported in this article can be extrapolated to other laboratory analyzers that were not used in the referenced studies.<br\/><br\/>For guidance regarding evaluating and addressing unexpected toxicology tests results, see <a target=\"_blank\" href=\"https:\/\/www.cdc.gov\/mmwr\/volumes\/71\/rr\/rr7103a1.htm#Recommendation10\">Recommendation 10 of the 22 CDC Clinical Practice Guideiline<\/a>.<\/p>\r\n  <\/div>\r\n<\/div>'

// Functions

define function GetPositiveLabsInPastYear(Labs List<FHIR.Observation>, Enabled Boolean):
  if Enabled
    then Labs Lab
     where StartsWith(Lower(Lab.value as FHIR.string), 'pos')
  else null

define function LabDetailsTuple(Ingredient String, Lab FHIR.Observation):
  {
    ingredient: Ingredient,
    date: date from FHIRHelpers.ToDateTime(Lab.effective as FHIR.dateTime),
    detailedIdentifier: Lab.code.coding[0].display.value
  }

define function GetUnexpectedColumn(Result String, Superscript String):
  '<td class=\"details-table-cell-unexpected\">' + Result + '<sup>' + Superscript + '<\/sup><\/td>'

define function GetExpectedColumn(Content String):
  '<td class=\"details-table-cell\">' + Content + '<\/td>'

// define function GetDetailsTableRow(Ingredient String, Detail Tuple{ingredient String, date Date, detailedIdentifier String}, Count Integer, UnexpectedNegative Boolean):
//   GetExpectedColumn(Ingredient) +
//     Combine(
//       "Positive Lab Dates In Past Year" PositiveDate
//         return (
//           if UnexpectedNegative and IndexOf("Positive Lab Dates In Past Year", PositiveDate) = 0
//             then GetUnexpectedColumn('neg', '*')
//           else if Detail.date same day as PositiveDate
//             then GetUnexpectedColumn('pos', ToString(Count))
//           else GetExpectedColumn('neg')
//         )
//     ) + '</tr>'

// define function GetDetailColumns(Ingredient String):
//   if not ("Lab Details".ingredient contains Ingredient)
//     then "All Negative"
//   else ResolveDetailColumns(Ingredient)

define function ResolveDetailColumns(Count Integer, Detail Tuple{ingredient String, date Date, detailedIdentifier String}):
  "Positive Lab Dates In Past Year" PositiveDate
    return all (
      if Detail.ingredient in "Opioid Ingredient List" and "Unexpected Negative Results On Latest UDS" and First("Positive Lab Dates In Past Year") = PositiveDate
        then GetUnexpectedColumn('neg', '*')
      else if Detail.date same day as PositiveDate
        then GetUnexpectedColumn('pos', ToString(Count))
      else 
        GetExpectedColumn('neg')
    )

// define function ResolveDetailColumns(Ingredient String):
//   "Lab Details" Detail
//     let Count: IndexOf("Lab Details", Detail) + 1
//     return all Combine(
//       "Positive Lab Dates In Past Year" PositiveDate
//         return all (
//           if Detail.ingredient in "Opioid Ingredient List" and "Unexpected Negative Results On Latest UDS" and First("Positive Lab Dates In Past Year") = PositiveDate
//             then GetUnexpectedColumn('neg', '*')
//           else if Detail.ingredient = Ingredient and Detail.date same day as PositiveDate
//             then GetUnexpectedColumn('pos', ToString(Count))
//           else if Detail.ingredient = Ingredient 
//             then GetExpectedColumn('neg')
//           else ''
//         )
//     )


















// using FHIR version '4.0.1'

// include FHIRHelpers version '4.0.1' called FHIRHelpers
// include OpioidCDSCommon version '2022.1.0' called Common
// include OpioidCDSRoutines version '2022.1.0' called Routines
// include OpioidCDSCommonConfig version '2022.1.0' called Config

// context Patient

// define "Lookback Year":
//   Interval[Today() - 12 months - 1 days, Today()]

// define "Lookback Year Excluding Today":
//   Interval[Today() - 12 months - 1 day, Today() - 1 day]

// define "Applicable Because of Unexpected Results":
//   HasPositiveScreeningInLast12Months("Cocaine Screenings", true)
//     or HasPositiveScreeningInLast12Months("PCP Screenings", true)
//     or HasPositiveScreeningInLast12Months("Cannabinoid Screenings", true)
//     or (
//       HasPositiveScreeningInLast12Months("Opiate Screenings", Config."Opiate Urine Screening Check Enabled")
//       and not "Has Active Prescription for Opiate?"
//     )
//     or (
//       HasPositiveScreeningInLast12Months("Synthetic Opioid Screenings", Config."Opiate Urine Screening Check Enabled")
//       and not "Has Active Prescription for Synthetic Opioid?"
//     )
//     or (
//       HasPositiveScreeningInLast12Months("Fentanyl Screenings", Config."Opiate Urine Screening Check Enabled")
//       and not "Has Active Prescription for Fentanyl?"
//     )
//     or (
//       HasPositiveScreeningInLast12Months("Amphetamine Screenings", true)
//       and not "Has Active Prescription for Amphetamine?"
//     )
//     or (
//       HasPositiveScreeningInLast12Months("Methadone Screenings", true)
//       and not "Has Active Prescription for Methadone?"
//     )

// define "Inclusion Criteria":
//   Routines."Is Opioid Review Useful?"
//   and (not "Patient had Urine Screening in Last 12 Months")

// define "Exclusion Criteria":
//   Common."End of Life Assessment"

// define "Patient had Urine Screening in Last 12 Months":
//   exists ("All Opioid or Non-opioid Screenings in Past Year")

// define "All Opioid or Non-opioid Screenings in Past Year":
//   [Observation] 

// define "Normalize Active Prescriptions":
//   Common."Get MedicationRequest Medication as Code"(Common."Active Medication List")

// define "Fentanyl Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."Fentanyl Urine Tests"

// define "Has Active Prescription for Fentanyl?":
//   exists (
//     "Normalize Active Prescriptions" ActiveRx
//       where ActiveRx.medication in Common."Fentanyl Medications"
//   )

// define "Amphetamine Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."Amphetamine Urine Tests"

// define "Has Active Prescription for Amphetamine?":
//   exists(
//     "Normalize Active Prescriptions" ActiveRx
//       where ActiveRx.medication in Common."Amphetamine Medications"
//   )

// define "Methadone Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."Methadone Urine Tests"

// define "Has Active Prescription for Methadone?":
//   exists(
//     "Normalize Active Prescriptions" ActiveRx
//       where ActiveRx.medication in Common."Methadone Medications"
//   )

// define "Opiate Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."Opiate Urine Tests"

// define "Has Active Prescription for Opiate?":
//   exists(
//     "Normalize Active Prescriptions" ActiveRx
//       where ActiveRx.medication in Common."Opiate Medications"
//   )

// define "Synthetic Opioid Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."Synthetic Opioid Urine Tests"

// define "Has Active Prescription for Synthetic Opioid?":
//   exists(
//     "Normalize Active Prescriptions" ActiveRx
//       where ActiveRx.medication in Common."Synthetic Opioid Medications"
//   )

// define "Cocaine Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."Cocaine Urine Tests"

// define "PCP Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."PCP Urine Tests"

// define "Cannabinoid Screenings":
//   "All Opioid or Non-opioid Screenings in Past Year" AllLabs
//     where AllLabs.code in Common."Cannabinoid Urine Tests"

// define function "GetRelevantScreenings" (obsList List<FHIR.Observation>):
//   obsList LabObservations
//      where date from LabObservations.effective in day of "Lookback Year"
//        and not (LabObservations.status.value in { 'unknown', 'entered-in-error', 'cancelled' })
//        and StartsWith(Lower(LabObservations.value as FHIR.string), 'pos')

// // Returns a text representation of a dateTime using the CQL `ToString` function.
// // @param d - a FHIR dateTime to get text for
// // @returns {System.String} the text representation of the dateTime
// define function "DateTimeText" (d FHIR.dateTime):
//   ToString(d.value)

// define function GetPositiveScreenings(Screenings List<FHIR.Observation>):
//   Screenings Screen where StartsWith(Lower(Screen.value as FHIR.string), 'pos')

// define function GetNegativeScreenings(Screenings List<FHIR.Observation>):
//   Screenings Screen where StartsWith(Lower(Screen.value as FHIR.string), 'neg')

// /*
//   borrowed from CDS4CPM CDS_Connect_Commons_for_FHIRv400
//   Should this go into OpioidCDSCommon?
// */
// define function "MostRecent" (ObsList List<Observation>):
//   Last(ObsList O sort by Coalesce(
//     (effective as FHIR.dateTime).value,
//     (effective as FHIR.Period)."end".value,
//     (effective as FHIR.Period)."start".value,
//     issued.value)
//   )

// define function GetNegativeScreeningsCount(Screenings List<FHIR.Observation>):
//   Count(
//     (GetNegativeScreenings(Screenings)) N
//       where DateTimeText(N.effective) > DateTimeText("MostRecent"(GetPositiveScreenings(Screenings)).effective)
//   )

// // define function GetPositiveDates(Screenings List<FHIR.Observation>):
// //   (GetPositiveScreenings(Screenings)) PositiveScreenings
// //     return DateTimeText(PositiveScreenings.effective)

// define function HasPositiveScreeningInLast12Months(Screenings List<FHIR.Observation>, Enabled Boolean):
//   if Enabled
//     then exists(Screenings Screen where StartsWith(Lower(Screen.value as FHIR.string), 'pos'))
//   else false

// // define function "Get Detail" (isScreeningRecommended Boolean):
// //   if isScreeningRecommended
// //     then 'Consider the Benefits and Risks of Conducting a Urine Toxicology Screen'
// //   else if "Applicable Because of Unexpected Results" 
// //     then 'Patient may have unexpected urine toxicology test results in the past year, including:'
// //       & GetUnexpectedResultsReport("Cocaine Screenings", 'Cocaine')
// //       & GetUnexpectedResultsReport("Opiate Screenings", 'Opiates')
// //       & GetUnexpectedResultsReport("PCP Screenings", 'PCP')
// //       & GetUnexpectedResultsReport("Fentanyl Screenings", 'Fentanyl')
// //       & GetUnexpectedResultsReport("Amphetamine Screenings", 'Amphetamines')
// //       & GetUnexpectedResultsReport("Cannabinoid Screenings", 'Cannabinoids')
// //       & GetUnexpectedResultsReport("Synthetic Opioid Screenings", 'Synthetic Opioids')
// //       & GetUnexpectedResultsReport("Methadone Screenings", 'Methadone')
// //       & '<br /><br />Note: Positive results may be false positives or could indicate the patient is an occasional user or addicted to the substance. For a review regarding interpreting possible false positive urine toxicology results, see https://pubmed.ncbi.nlm.nih.gov/24986836/. It is unknown if the findings reported in this article can be extrapolated to other laboratory analyzers that were not used in the referenced studies. For guidance regarding evaluating and addressing unexpected toxicology test results, see [Recommendation 10 of the 2022 CDC Clinical Practice Guideline](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#Recommendation10).'
// //   else
// //       null

// define function "Get Summary" (isScreeningRecommended Boolean):
//   if isScreeningRecommended
//     then 'Consider the benefits and risks of toxicology testing to assess for prescribed medications as well as other prescribed and nonprescribed controlled substances.'
//   else if "Applicable Because of Unexpected Results" 
//     then 'Patient May Have Unexpected Toxicology Test Results'
//   else null

// // define function GetUnexpectedResultsReport(Screenings List<FHIR.Observation>, Type String):
// //   if Length(Screenings) = 0 then null
// //   else if exists GetPositiveScreenings(Screenings)
// //     then '<br />*Positive for ' + Type + ': ' +
// //     Combine(GetPositiveDates(Screenings), ', ') +
// //       (
// //         if GetNegativeScreeningsCount(Screenings) > 0
// //           then '  (' + ToString(GetNegativeScreeningsCount(Screenings)) +
// //           ' negative since)'
// //         else ''
// //       )
// //   else null

// // define "Positive Dates List":
// //   distinct (
// //     "Positive Screenings List" Screenings
// //       return Screenings.date
// //   )

// // define "Details Table Info":
// //   {
// //     ingredient: 'Cocaine',
// //     screenings: (
// //       ("GetRelevantScreenings"("Cocaine Screenings")) PositiveCocaineScreenInPastYear
// //         return {
// //           date: date from FHIRHelpers.ToDateTime(PositiveCocaineScreenInPastYear.effective as FHIR.dateTime),
// //           detailedIdentifier: PositiveCocaineScreenInPastYear.code.coding.display
// //         }
// //     ) X sort by date desc
// //   }

// define "Positive Dates List":
//   (distinct flatten (
//    "Details Table Info" Info
//       return Info.screenings.date
//   )) X sort desc

// define "Details Table Info":
//   {
//     BuildDetailsInfo('Amphetamine', "GetRelevantScreenings"("Amphetamine Screenings")),
//     BuildDetailsInfo('Cannabinoid', "GetRelevantScreenings"("Cannabinoid Screenings")),
//     BuildDetailsInfo('Cocaine', "GetRelevantScreenings"("Cocaine Screenings")),
//     BuildDetailsInfo('Fentanyl', "GetRelevantScreenings"("Fentanyl Screenings")),
//     BuildDetailsInfo('Methadone', "GetRelevantScreenings"("Methadone Screenings")),
//     BuildDetailsInfo('Opiate', "GetRelevantScreenings"("Opiate Screenings")),
//     BuildDetailsInfo('PCP', "GetRelevantScreenings"("PCP Screenings")),
//     BuildDetailsInfo('Synthetic Opioid', "GetRelevantScreenings"("Synthetic Opioid Screenings"))
//   }

// define function BuildDetailsInfo(SimpleIngredientIdentifier String, PositiveScreeningsInPastYear List<FHIR.Observation>):
//   {
//     ingredient: SimpleIngredientIdentifier,
//     screenings: (
//       PositiveScreeningsInPastYear Screening
//         return {
//           date: date from FHIRHelpers.ToDateTime(Screening.effective as FHIR.dateTime),
//           detailedIdentifier: Screening.code.coding[0].display
//         }
//     ) X sort by date desc
//   }

// // define "Random Symbols":
// //   {'⌀', '∀', '∞', '∃', '∇', '^', '∫', '∝'}

// define ScreeningDetails:
//   "Details Table Info".screenings

// define "Add Footnote Symbols":
//   "Details Table Info" Info
//     let simpleIngredient: Info.ingredient
//     return {
//       screenings: (
//         Info.screenings Screening
//           return {
//             ingredient: simpleIngredient,
//             date: Screening.date,
//             detailedIdentifier: Screening.detailedIdentifier,
//             footnoteSymbol: IndexOf(ScreeningDetails, Screening) + 1
//           }
//       )
//     }

// define "Unexpected Rows":
//   "Add Footnote Symbols".screenings Info
//     return all (
//       "Table Row Start" + "Table Cell Normal Start" + Info.ingredient + "Table Cell End" +
//       Combine(
//         "Positive Dates List" positiveDate
//           return all (
//             if Info.date same day as positiveDate
//               then "Table Cell Unexpected Start" + 'pos' + '<sup>' + ToString(Info.footnoteSymbol) + '</sup>' + "Table Cell End"
//             else "Table Cell Normal Start" + 'neg' + "Table Cell End"
//           )
//       )
//       + "Table Row End"
//     )

// // define "Unexpected Rows":
// //   "Add Footnote Symbols" Info
// //     return all (
// //       "Table Row Start" + "Table Cell Normal Start" + Info.ingredient + "Table Cell End" +
// //       Combine(
// //         "Positive Dates List" positiveDate
// //           return all (
// //             if Info.screenings.date contains positiveDate
// //               then "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
// //             else "Table Cell Normal Start" + 'neg' + "Table Cell End"
// //           )
// //       )
// //       + "Table Row End"
// //     )

// define "Table Footer Rows":
//   "Add Footnote Symbols".screenings Info
//     return all (
//       if Info.detailedIdentifier is not null
//         then "Table Row Start" + "Table Footer Cell Normal Start" + ToString(Info.footnoteSymbol) + '- ' + Info.detailedIdentifier + "Table Cell End"
//       else ''
//     )

// define "Table Footer Start":
//   '<tfoot>'

// define "Table Footer End":
//   '</tfoot>'

// define "Table Footer":
//   "Table Footer Start" + Combine("Table Footer Rows") + "Table Footer End"

// // define "Table Footer Rows":
// //   "Details Table Info" Info
// //     let count: 0
// //     return (
// //       if exists (Info.screenings.detailedIdentifier)
// //         then '<tr>' + '<td>' + ToString(count+1) + '- ' + Info.screenings.detailedIdentifier.value
// //       else ''
// //     )

// // define "Table Footer":
// //   "Details Table Info" Info
// //     let count: 0
// //     return (
// //       if Count = 0
// //         then ''
// //       else (
// //         if exists (Info.screenings.detailedIdentifier)
// //           then '<tfoot>' + Info.screenings.detailedIdentifier
// //       )
// //     )

// // define "Positive Dates List":
// //   (distinct flatten (
// //     "Positive Screenings List" Screenings
// //       return Screenings.dates
// //   )) X sort asc

// define function GetPositiveDates(Screenings List<Observation>):
//   Screenings Screening
//     where StartsWith(Lower(Screening.value as FHIR.string), 'pos')
//     return (date from FHIRHelpers.ToDateTime(Screening.effective as FHIR.dateTime)) sort asc

// define "Positive Cocaine Screenings": GetPositiveDates("Cocaine Screenings")

// define "Positive PCP Screenings": GetPositiveDates("PCP Screenings")

// define "Positive Cannabinoid Screenings": GetPositiveDates("Cannabinoid Screenings")

// define "Positive Amphetamine Screenings": GetPositiveDates("Amphetamine Screenings")

// define "Positive Methadone Screenings": GetPositiveDates("Methadone Screenings")

// define "Positive Opiate Screenings": 
//   if Config."Opiate Urine Screening Check Enabled" 
//     then GetPositiveDates("Opiate Screenings")
//   else null

// define "Positive Synthetic Opioid Screenings": 
//   if Config."Opiate Urine Screening Check Enabled" 
//     then GetPositiveDates("Synthetic Opioid Screenings")
//   else null

// define "Positive Fentanyl Screenings": 
//   if Config."Opiate Urine Screening Check Enabled" 
//     then GetPositiveDates("Fentanyl Screenings")
//   else null

// define "Positive Screenings List":
//   {
//     ( {
//         ingredient: 'Cocaine',
//         dates: "Positive Cocaine Screenings"
//       } ), ( {
//         ingredient: 'PCP',
//         dates: "Positive PCP Screenings"
//       } ), ( {
//         ingredient: 'Cannabinoid',
//         dates: "Positive Cannabinoid Screenings"
//       } ), ( {
//         ingredient: 'Amphetamine',
//         dates: "Positive Amphetamine Screenings"
//       } ), ( {
//         ingredient: 'Methadone',
//         dates: "Positive Methadone Screenings"
//       } ), ( {
//         ingredient: 'Opiate',
//         dates: "Positive Opiate Screenings"
//       } ), ( {
//         ingredient: 'Synthetic Opioid',
//         dates: "Positive Synthetic Opioid Screenings"
//       } ), ( {
//         ingredient: 'Fentanyl',
//         dates: "Positive Fentanyl Screenings"
//       } )
//   }

// // define "Unexpected Rows":
// //   "Positive Screenings List" Screenings
// //     return all (
// //       "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End" +
// //       Combine(
// //         "Positive Dates List" positiveDate
// //           return all (
// //             if Screenings.dates contains positiveDate
// //               then "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
// //             else "Table Cell Normal Start" + 'neg' + "Table Cell End"
// //           )
// //       )
// //       + "Table Row End"
// //     )

// // define "Positive Screenings List":
// //   (
// //     (
// //     "Cocaine Screenings" CocaineScreening
// //       where StartsWith(Lower(CocaineScreening.value as FHIR.string), 'pos')
// //       return {
// //         ingredient: 'Cocaine',
// //         date: date from FHIRHelpers.ToDateTime(CocaineScreening.effective as FHIR.dateTime)
// //       }
// //     ) union (
// //       "PCP Screenings" PCPScreening
// //         where StartsWith(Lower(PCPScreening.value as FHIR.string), 'pos')
// //         return {
// //           ingredient: 'PCP',
// //           date: date from FHIRHelpers.ToDateTime(PCPScreening.effective as FHIR.dateTime)
// //         }
// //     ) union (
// //       "Cannabinoid Screenings" THCScreening
// //         where StartsWith(Lower(THCScreening.value as FHIR.string), 'pos')
// //         return {
// //           ingredient: 'Cannabinoid',
// //           date: date from FHIRHelpers.ToDateTime(THCScreening.effective as FHIR.dateTime)
// //         }
// //     ) union (
// //       if Config."Opiate Urine Screening Check Enabled" 
// //         then (
// //           "Opiate Screenings" OpiateScreening
// //             where StartsWith(Lower(OpiateScreening.value as FHIR.string), 'pos')
// //             return {
// //               ingredient: 'Opiate',
// //               date: date from FHIRHelpers.ToDateTime(OpiateScreening.effective as FHIR.dateTime)
// //             }
// //         )
// //       else null
// //     ) union (
// //       if Config."Opiate Urine Screening Check Enabled" 
// //         then (
// //           "Synthetic Opioid Screenings" SyntheticOpioidScreening
// //             where StartsWith(Lower(SyntheticOpioidScreening.value as FHIR.string), 'pos')
// //             return {
// //               ingredient: 'Synthetic Opioid',
// //               date: date from FHIRHelpers.ToDateTime(SyntheticOpioidScreening.effective as FHIR.dateTime)
// //             }
// //         )
// //       else null
// //     ) union (
// //       if Config."Opiate Urine Screening Check Enabled" 
// //         then (
// //           "Fentanyl Screenings" FentanylScreening
// //             where StartsWith(Lower(FentanylScreening.value as FHIR.string), 'pos')
// //             return {
// //               ingredient: 'Fentanyl',
// //               date: date from FHIRHelpers.ToDateTime(FentanylScreening.effective as FHIR.dateTime)
// //             }
// //         )
// //       else null
// //     ) union (
// //       "Amphetamine Screenings" AmphetamineScreening
// //         where StartsWith(Lower(AmphetamineScreening.value as FHIR.string), 'pos')
// //         return {
// //           ingredient: 'Amphetamine',
// //           date: date from FHIRHelpers.ToDateTime(AmphetamineScreening.effective as FHIR.dateTime)
// //         }
// //     ) union (
// //       "Methadone Screenings" MethadoneScreening
// //         where StartsWith(Lower(MethadoneScreening.value as FHIR.string), 'pos')
// //         return {
// //           ingredient: 'Methadone',
// //           date: date from FHIRHelpers.ToDateTime(MethadoneScreening.effective as FHIR.dateTime)
// //         }
// //     )
// //   ) X sort by date

// define "Get Unexpected Details Table":
//   Common."Style Header" + "Unexpected Div Start" + "Table Start" + Combine("Table Columns") + "Table Row End" + Combine("Unexpected Rows") + "Table Footer" + "Table End" + "Details More Info" + "Unexpected Div End"

// // define "Get Unexpected Details Table":
// //   Common."Style Header" + "Unexpected Div Start" + "Table Start" + Combine("Table Columns") + "Table Row End" + Combine("Unexpected Rows") + "Table End" + "Details More Info" + "Unexpected Div End"

// // define "Unexpected Rows":
// //   "Positive Screenings List" Screenings
// //     return (
// //       "Table Row Start" + "Table Cell Normal Start" + Screenings.ingredient + "Table Cell End"
// //       + (
// //         (IndexOf("Positive Dates List", Screenings.date)) Idx 
// //           return (
// //             if Idx = -1
// //               then "Table Cell Normal Start" + 'neg' + "Table Cell End"
// //             else "Table Cell Unexpected Start" + 'pos' + "Table Cell End"
// //           )
// //       ) + "Table Row End"
// //     )

// define "Table Cell End":
//   '<\/td>'

// define "Table Cell Unexpected Start":
//   '<td class=\"details-table-cell-unexpected\">'

// define "Table Cell Normal Start":
//   '<td class=\"details-table-cell\">'

// define "Table Footer Cell Normal Start":
//   '<td colspan=\"' + ToString(Length("Positive Dates List")) + '\" ' + 'class=\"details-table-cell\">'

// define "Table Row Start":
//   '<tr>'

// define "Table Row End":
//   '<\/tr>'

// define "Table Columns":
//   "Positive Dates List" Dates
//     return '<th class=\"details-table-header\">' + ToString(Dates) + '<\/th>'

// // define "Table Columns":
// //   "Positive Dates List" Dates
// //     return '<th class=\"details-table-header\">' + ToString(Dates) + '<\/th>'

// define "Unexpected Div Start":
//   '<div class=\"alert-body\"><div><p>Patient may have <strong>unexpected urine toxicology test results<\/strong> in the past year, including:<\/p><\/div>'

// define "Unexpected Div End":
//   '</div>'

// define "Table Start":
//   '<div><table class=\"details-table\"><caption class=\"details-caption\">Urine Toxicology Results<\/caption><tr><th class=\"details-table-header\">Substance<\/th>'

// define "Table End":
//   '<\/table><\/div>'

// define "Details More Info":
//   '<div id=\"box\">\r\n  <p>Note on false positives...<\/p>\r\n  <input type=\"checkbox\" class=\"show-more\"> Show more\r\n  <div class=\"more\">\r\n    <p>Positive results may be a false positives or could represent occasional use or possible substance use disorder.<br\/><br\/>For a review regarding interpreting possible false positive urine toxicology results, see <a target=\"_blank\" href=\"https:\/\/pubmed.ncbi.nlm.nih.gov\/24986836\">http:\/\/pubmed.ncbi.nlm.nih.gov\/24986836<\/a>. It is unknown if the findings reported in this article can be extrapolated to other laboratory analyzers that were not used in the referenced studies.<br\/><br\/>For guidance regarding evaluating and addressing unexpected toxicology tests results, see <a target=\"_blank\" href=\"https:\/\/www.cdc.gov\/mmwr\/volumes\/71\/rr\/rr7103a1.htm#Recommendation10\">Recommendation 10 of the 22 CDC Clinical Practice Guideiline<\/a>.<\/p>\r\n  <\/div>\r\n<\/div>'

// /* 

// The details table should provide the following information:
//   * Unexpected results
//     * Includes positive toxicology results for an unprescribed medication from the following list: Amphetamine, Cannabinoid, Cocaine, Fentanyl, Methadone, Opiate, PCP, Synthetic Opioid
//     * Includes negative toxicology results for prescribed medications where the lab falls within the expected supply duration for a medication (detect diversion and/or misuse)
//     * The unexpected result will be displayed in bold red text with either an "*" or "**" with a footnote explaining the asterisk meaning
//       * "*" denotes positive toxicology results for unprescribed medications
//       * "**" denotes negative toxicology results for prescribed medications

// */