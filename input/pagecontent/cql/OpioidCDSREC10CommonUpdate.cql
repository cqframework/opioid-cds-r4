library OpioidCDSREC10CommonUpdate version '2022.1.0'

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

define "Unexpected Positive Details Combined":
  {
    LabDetailsTupleCombined("Amphetamine Simple Identifier", "Amphetamine Screenings"),
    LabDetailsTupleCombined("Cannabinoid Simple Identifier", "Cannabinoid Screenings"),
    LabDetailsTupleCombined("Cocaine Simple Identifier", "Cocaine Screenings"),
    LabDetailsTupleCombined("Fentanyl Simple Identifier", "Fentanyl Screenings"),
    LabDetailsTupleCombined("Methadone Simple Identifier", "Methadone Screenings"),
    LabDetailsTupleCombined("Opiate Simple Identifier", "Opiate Screenings"),
    LabDetailsTupleCombined("PCP Simple Identifier", "PCP Screenings"),
    LabDetailsTupleCombined("Synthetic Opioid Simple Identifier", "Synthetic Opioid Screenings")
  }

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
        return '<tr>' + GetExpectedColumn(Details.ingredient) 
          + Combine(
            distinct ("Unexpected Positive Details Combined" CombinedDetails 
              return (
                if Details.ingredient = CombinedDetails.ingredient
                  then ResolveDetailColumns(Count, CombinedDetails)
                else ''
              ))
          ) + '<\/tr>'

// define "Unexpected Details Table Rows":
//   "Lab Details" Details
//     let Count: IndexOf("Lab Details", Details) + 1
//     return '<tr>' + GetExpectedColumn(Details.ingredient) + Combine(ResolveDetailColumns(Count, Details)) + '<\/tr>'

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

define function LabDetailsTupleCombined(Ingredient String, Labs List<FHIR.Observation>):
  {
    ingredient: Ingredient,
    info: (
      Labs Lab
        return {
          date: date from FHIRHelpers.ToDateTime(Lab.effective as FHIR.dateTime),
          detailedIdentifier: if exists (Lab.code.coding) then Lab.code.coding[0].display.value else 'Unable to determine a detailed identifier'
        }
    )
  }

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

define function ResolveDetailColumns(Count Integer, Detail Tuple{ingredient String, info List<Tuple{date Date, detailedIdentifier String}>}):
  "Positive Lab Dates In Past Year" PositiveDate
    return all (
      if Detail.ingredient in "Opioid Ingredient List" and "Unexpected Negative Results On Latest UDS" and First("Positive Lab Dates In Past Year") = PositiveDate
        then GetUnexpectedColumn('neg', '*')
      else if Detail.info.date contains PositiveDate
        then GetUnexpectedColumn('pos', ToString(Count))
      else 
        GetExpectedColumn('neg')
    )

// define function ResolveDetailColumns(Count Integer, Detail Tuple{ingredient String, date Date, detailedIdentifier String}):
//   "Positive Lab Dates In Past Year" PositiveDate
//     return all (
//       if Detail.ingredient in "Opioid Ingredient List" and "Unexpected Negative Results On Latest UDS" and First("Positive Lab Dates In Past Year") = PositiveDate
//         then GetUnexpectedColumn('neg', '*')
//       else if Detail.date same day as PositiveDate
//         then GetUnexpectedColumn('pos', ToString(Count))
//       else 
//         GetExpectedColumn('neg')
//     )

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
