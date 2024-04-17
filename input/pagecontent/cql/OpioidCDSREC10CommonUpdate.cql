library OpioidCDSREC10CommonUpdate version '2022.1.0'

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
