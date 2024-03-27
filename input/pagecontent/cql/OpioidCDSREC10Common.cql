library OpioidCDSREC10Common version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSRoutines version '2022.1.0' called Routines
include OpioidCDSCommonConfig version '2022.1.0' called Config

context Patient

// Constants

define "UDS Lookback Period":
  Interval[Today() - 12 months - 1 days, Today()]

define "Rx Lookback Period":
  Interval[Today() - 12 months - 31 days, Today()]

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

/*
@description: Determines whether an opioid review is appropriate for the patient and whether they had a UDS performed in the past year
*/
define "Inclusion Criteria For UDS Recommendation":
  Routines."Is Opioid Review Useful?"
    and not exists ("All Opioid or Non-opioid UDS in Lookback Period")

define "Inclusion Criteria For Unexpected Results":
  AnyTrue(
    "Unexpected Details" Details
      return (exists Details.unexpectedPosDetails) or (exists Details.unexpectedNegDetails)
  )

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "All Opioid or Non-opioid UDS in Lookback Period":
  (
    [Observation: Common."All Drug Urine Screening"] Lab
      where date from Lab.effective in day of "UDS Lookback Period"
        and not (Lab.status.value in { 'unknown', 'entered-in-error', 'cancelled' })
  ) X sort by date from FHIRHelpers.ToDateTime(effective as FHIR.dateTime) desc

// Amphetamines
define "Amphetamine Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" Lab
    where Lab.code in Common."Amphetamine Urine Tests"

define "Positive Amphetamine Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Amphetamine Screenings In Lookback Period", true)

define "Negative Amphetamine Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" except "Positive Amphetamine Screenings In Lookback Period"

define "Amphetamine Rx In Lookback Period":
  "Normalize Rx In Lookback Period" Rx
      where Rx.medication in Common."Amphetamine Medications"

// Cannabinoids
define "Cannabinoid Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" Lab
    where Lab.code in Common."Cannabinoid Urine Tests"

define "Positive Cannabinoid Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Cannabinoid Screenings In Lookback Period", true)

// Cocaine
define "Cocaine Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" Lab
    where Lab.code in Common."Cocaine Urine Tests"

define "Positive Cocaine Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Cocaine Screenings In Lookback Period", true)

// Fentanyl
define "Fentanyl Screenings In Lookback Period":
  if Config."Opiate Urine Screening Check Enabled"
  then (
    "All Opioid or Non-opioid UDS in Lookback Period" AllLabs
      where AllLabs.code in Common."Fentanyl Urine Tests"
  ) else null

define "Positive Fentanyl Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Fentanyl Screenings In Lookback Period", Config."Opiate Urine Screening Check Enabled")

define "Negative Fentanyl Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" except "Positive Fentanyl Screenings In Lookback Period"

define "Fentanyl Rx In Lookback Period":
  "Normalize Rx In Lookback Period" Rx
    where Rx.medication in Common."Fentanyl Medications"

// Methadone
define "Methadone Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" Lab
    where Lab.code in Common."Methadone Urine Tests"

define "Positive Methadone Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Methadone Screenings In Lookback Period", true)

define "Negative Methadone Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" except "Positive Methadone Screenings In Lookback Period"

define "Methadone Rx In Lookback Period":
  "Normalize Rx In Lookback Period" Rx
      where Rx.medication in Common."Methadone Medications"

// Opiates
define "Opiate Screenings In Lookback Period":
  if Config."Opiate Urine Screening Check Enabled"
    then (
      "All Opioid or Non-opioid UDS in Lookback Period" Lab
        where Lab.code in Common."Opiate Urine Tests"
    ) else null

define "Positive Opiate Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Opiate Screenings In Lookback Period", Config."Opiate Urine Screening Check Enabled")

define "Negative Opiate Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" except "Positive Opiate Screenings In Lookback Period"

define "Opiate Rx In Lookback Period":
  "Normalize Rx In Lookback Period" Rx
      where Rx.medication in Common."Opiate Medications"

// Opioids
// TODO: This logic will likely need some tuning to prevent collisions with other opioid substances (Fentanyl, Methadone, Opiates, and Synthetic Opioids)
define "Opioid Screenings In Lookback Period":
  if Config."Opiate Urine Screening Check Enabled"
    then (
      "All Opioid or Non-opioid UDS in Lookback Period" Lab
        where Lab.code in Common."Opioid drug urine screening"
    ) else null

define "Positive Opioid Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Opioid Screenings In Lookback Period", Config."Opiate Urine Screening Check Enabled")

define "Negative Opioid Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" except "Positive Opioid Screenings In Lookback Period"

define "Opioid Rx In Lookback Period":
  "Normalize Rx In Lookback Period" Rx
      where Rx.medication in Common."Opioid analgesics with ambulatory misuse potential"

// PCP
define "PCP Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" AllLabs
    where AllLabs.code in Common."PCP Urine Tests"

define "Positive PCP Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("PCP Screenings In Lookback Period", true)

// Synthetic Opioids
define "Synthetic Opioid Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" Lab
    where Lab.code in Common."Synthetic Opioid Urine Tests"

define "Positive Synthetic Opioid Screenings In Lookback Period":
  GetPositiveLabsInLookbackPeriod("Synthetic Opioid Screenings In Lookback Period", Config."Opiate Urine Screening Check Enabled")

define "Negative Synthetic Opioid Screenings In Lookback Period":
  "All Opioid or Non-opioid UDS in Lookback Period" except "Positive Synthetic Opioid Screenings In Lookback Period"

define "Synthetic Opioid Rx In Lookback Period":
  "Normalize Rx In Lookback Period" Rx
      where Rx.medication in Common."Synthetic Opioid Medications"

// Helpers  

define "All Positive Labs In Lookback Period":
  "Amphetamine Screenings In Lookback Period" union "Cannabinoid Screenings In Lookback Period" 
    union "Cocaine Screenings In Lookback Period" union "Fentanyl Screenings In Lookback Period" 
    union "Methadone Screenings In Lookback Period" union "Opiate Screenings In Lookback Period" 
    union "PCP Screenings In Lookback Period" union "Synthetic Opioid Screenings In Lookback Period"

define "All Lab Dates in Lookback Period":
  (
    "All Opioid or Non-opioid UDS in Lookback Period" Lab
      return date from FHIRHelpers.ToDateTime(Lab.effective as FHIR.dateTime)
  ) X sort desc

define "Positive Lab Dates In Lookback Period":
  (
    "All Positive Labs In Lookback Period" Lab
      return date from FHIRHelpers.ToDateTime(Lab.effective as FHIR.dateTime)
  ) X sort desc

define "Normalize Rx In Lookback Period":
  Common."Get MedicationRequest Medication as Code"(
    [MedicationRequest: status in { 'active', 'completed', 'stopped' }] Rx
      where Rx.category in Common."Community"
        and Rx.intent = 'order'
        and Rx.authoredOn.value in day of "Rx Lookback Period"
  )

// Details Logic

define "Unexpected Details":
  {
    CreateDetailWithPossibleUnexpectedNegative(
      "Amphetamine Simple Identifier", "Positive Amphetamine Screenings In Lookback Period", 
      "Negative Amphetamine Screenings In Lookback Period", "Amphetamine Rx In Lookback Period"
    ),
    CreateDetailWithoutPossibleUnexpectedNegative(
      "Cannabinoid Simple Identifier", "Positive Cannabinoid Screenings In Lookback Period"
    ),
    CreateDetailWithoutPossibleUnexpectedNegative(
      "Cocaine Simple Identifier", "Positive Cocaine Screenings In Lookback Period"
    ),
    CreateDetailWithPossibleUnexpectedNegative(
      "Fentanyl Simple Identifier", "Positive Fentanyl Screenings In Lookback Period", 
      "Negative Fentanyl Screenings In Lookback Period", "Fentanyl Rx In Lookback Period"
    ),
    CreateDetailWithPossibleUnexpectedNegative(
      "Methadone Simple Identifier", "Positive Methadone Screenings In Lookback Period", 
      "Negative Methadone Screenings In Lookback Period", "Methadone Rx In Lookback Period"
    ),
    CreateDetailWithPossibleUnexpectedNegative(
      "Opiate Simple Identifier", "Positive Opiate Screenings In Lookback Period", 
      "Negative Opiate Screenings In Lookback Period", "Opiate Rx In Lookback Period"
    ),
    CreateDetailWithPossibleUnexpectedNegative(
      "Opioid Simple Identifier", "Positive Opioid Screenings In Lookback Period", 
      "Negative Opioid Screenings In Lookback Period", "Opioid Rx In Lookback Period"
    ),
    CreateDetailWithoutPossibleUnexpectedNegative(
      "PCP Simple Identifier", "Positive PCP Screenings In Lookback Period"
    ),
    CreateDetailWithPossibleUnexpectedNegative(
      "Synthetic Opioid Simple Identifier", "Positive Synthetic Opioid Screenings In Lookback Period", 
      "Negative Synthetic Opioid Screenings In Lookback Period", "Synthetic Opioid Rx In Lookback Period"
    )
  }

// HTML Generation

define "Get HTML Details":
  Common."Style Header" + "Unexpected Div Start" + "Details Table" + "Details More Info" + "Div End"

define "Unexpected Div Start":
  '<div class=\"alert-body\"><div><p>Patient may have <strong>unexpected urine toxicology test results<\/strong> in the past year.<\/p><\/div>'

define "Details Table": 
  "Table Start" + Combine("Table Headers") 
    + '<tbody>' + Combine("Generate Table Rows") + '</tbody>' 
    + '<tfoot>' + Combine("Generate Footer Rows") + '<\/tfoot>' 
  + "Table End"

define "Table Start":
  '<div><table class=\"details-table\"><caption class=\"details-caption\">Urine Toxicology Results<\/caption><tr><th class=\"details-table-header\">Substance<\/th>'

define "Table Headers":
  "All Lab Dates in Lookback Period" LabDate
    return '<th class=\"details-table-header\">' + ToString(LabDate) + '<\/th>'

define "Generate Table Rows":
  "Unexpected Details" BOT
    let row: ToString(IndexOf("Unexpected Details", BOT) + 1)
    return '<tr>' + GetExpectedColumn(BOT.ingredient) + Combine(
      "All Lab Dates in Lookback Period" LabDate
        let col: ToString(IndexOf("All Lab Dates in Lookback Period", LabDate) + 2)
        return all (
          if BOT.unexpectedPosDetails.date contains LabDate
            then GetUnexpectedColumn('pos', row + col)
          else if BOT.unexpectedNegDetails.udsDate contains LabDate
            then GetUnexpectedColumn('neg', row + col)
          else if BOT.posDates contains LabDate
            then GetExpectedColumn('pos')
          else GetExpectedColumn('neg')
        )
    ) + '<\/tr>'

define "Generate Footer Rows":
  "Unexpected Details" BOT
      let row: ToString(IndexOf("Unexpected Details", BOT) + 1),
      colspan: Length("All Lab Dates in Lookback Period") + 1
      return Combine(
        "All Lab Dates in Lookback Period" LabDate
          let col: ToString(IndexOf("All Lab Dates in Lookback Period", LabDate) + 2)
          return all (
            if BOT.unexpectedPosDetails.date contains LabDate
              then singleton from (
                BOT.unexpectedPosDetails PosDetail
                  where PosDetail.date = LabDate
                    return '<tr>' + GetFooterColumn(colspan, row + col + ' - Possible unprescribed substance found: ' + PosDetail.udsDetail) + '<\/tr>'
              )
            else if BOT.unexpectedNegDetails.udsDate contains LabDate
              then singleton from (
                BOT.unexpectedNegDetails NegDetail
                  where NegDetail.udsDate = LabDate
                    return '<tr>' + GetFooterColumn(colspan, row + col + ' - Possible diversion found: prescribed ' + NegDetail.rxDetail + ' on ' + ToString(NegDetail.rxDate)) + '<\/tr>'
              )
            else ''
          )
      )

define "Table End":
  '<\/table><\/div>'

define "Details More Info":
  '<div id=\"box\">\r\n  <p>Note on false positives...<\/p>\r\n  <input type=\"checkbox\" class=\"show-more\"> Show more\r\n  <div class=\"more\">\r\n'
     + '<p>Positive results may be a false positives or could represent occasional use or possible substance use disorder.<br\/><br\/>For a review regarding interpreting possible false positive urine toxicology results, see <a target=\"_blank\" href=\"https:\/\/pubmed.ncbi.nlm.nih.gov\/24986836\">http:\/\/pubmed.ncbi.nlm.nih.gov\/24986836<\/a>. It is unknown if the findings reported in this article can be extrapolated to other laboratory analyzers that were not used in the referenced studies.<br\/><br\/>For guidance regarding evaluating and addressing unexpected toxicology tests results, see <a target=\"_blank\" href=\"https:\/\/www.cdc.gov\/mmwr\/volumes\/71\/rr\/rr7103a1.htm#Recommendation10\">Recommendation 10 of the 22 CDC Clinical Practice Guideiline<\/a>.<\/p>\r\n  <\/div>\r\n<\/div>'

define "Div End": '<\/div>'

// Functions

define function GetUnexpectedColumn(Result String, Superscript String):
  '<td class=\"details-table-cell-unexpected\">' + Result + '<sup>' + Superscript + '<\/sup><\/td>'

define function GetExpectedColumn(Content String):
  '<td class=\"details-table-cell\">' + Content + '<\/td>'

define function GetFooterColumn(colspan Integer, message String):
  '<td class=\"details-table-cell\"' + ' colspan=' + ToString(colspan) + '>' + message + '<\/td>'

define function CreateDetailWithPossibleUnexpectedNegative(TheSubstance String, ThePosLabs List<Observation>, TheNegLabs List<Observation>, TheMeds List<MedicationRequest>):
  {
    ingredient: TheSubstance,
    posDates: (
      ThePosLabs PosLab
        return date from FHIRHelpers.ToDateTime(PosLab.effective as FHIR.dateTime)
    ),
    unexpectedPosDetails: (
      ThePosLabs PosLab
        with TheMeds Rx
          such that not (Rx.authoredOn in day of Interval[PosLab.effective - 31 days, PosLab.effective - 1 days])
            return {
              date: date from FHIRHelpers.ToDateTime(PosLab.effective as FHIR.dateTime),
              udsDetail: if exists (PosLab.code.coding) then PosLab.code.coding[0].display.value else 'Unable to determine a detailed identifier'
            }
    ),
    unexpectedNegDetails: (
      from TheNegLabs NegLab,
        TheMeds Rx
          where (Rx.authoredOn in day of Interval[NegLab.effective - 31 days, NegLab.effective - 1 days])
            return {
              udsDate: date from FHIRHelpers.ToDateTime(NegLab.effective as FHIR.dateTime),
              udsDetail: if exists (NegLab.code.coding) then NegLab.code.coding[0].display.value else 'Unable to determine a detailed identifier',
              rxDate: date from FHIRHelpers.ToDateTime(Rx.authoredOn as FHIR.dateTime),
              rxDetail: if exists (Rx.medication.coding) then Rx.medication.coding[0].display.value else 'Unable to determine a detailed identifier'
            }
    )
  }

define function CreateDetailWithoutPossibleUnexpectedNegative(TheSubstance String, ThePosLabs List<Observation>):
  {
    ingredient: TheSubstance,
    posDates: (
      ThePosLabs PosLab
        return date from FHIRHelpers.ToDateTime(PosLab.effective as FHIR.dateTime)
    ),
    unexpectedPosDetails: (
      ThePosLabs PosLab
        return {
          date: date from FHIRHelpers.ToDateTime(PosLab.effective as FHIR.dateTime),
          udsDetail: if exists (PosLab.code.coding) then PosLab.code.coding[0].display.value else 'Unable to determine a detailed identifier'
        }
    ),
    unexpectedNegDetails: {
      null as Tuple{udsDate System.Date, udsDetail System.String, rxDate System.Date, rxDetail System.String}
    }
  }

define function GetPositiveLabsInLookbackPeriod(Labs List<FHIR.Observation>, Enabled Boolean):
  if Enabled
    then Labs Lab
     where StartsWith(Lower(Lab.value as FHIR.string), 'pos')
  else null

define function HasRxInLookbackPeriod(Meds List<FHIR.MedicationRequest>, LookbackPeriod Interval<DateTime>):
  AnyTrue(
    Meds Rx return Rx.authoredOn in day of LookbackPeriod
  )



















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