library OpioidCDSREC08 version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers  version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSCommonConfig version '2022.1.0' called Config
include OpioidCDSRoutines version '2022.1.0' called Routines
/*include fhir.cdc."opioid-mme-r4".MMECalculator version '3.0.0' called MMECalculator
 */
include MMECalculator version '3.0.0' called MMECalculator

/*
**
**  Recommendation #8
**    Before starting and periodically during continuation of opioid therapy, clinicians should 
**    evaluate risk for opioid-related harms and discuss risk with patients. Clinicians should 
**    work with patients to incorporate into the management plan strategies to mitigate risk, 
**    including offering naloxone (recommendation category: A; evidence type: 4).
**
**  When
**    Order for opioid analgesics with ambulatory misuse potential:
**    Opioid review is useful for this patient:
**      Patient is 18 or over
**      Patient does not have evidence of sickle cell disease
**      Patient does not have findings indicating limited life expectancy
**      Patient does not have orders for therapies indicating end of life care
**      Patient is not undergoing active cancer treatment:
**        Patient has had at least 2 office visits within the past 12 months with an oncology specialist present, or
**        Patient has had at least 2 office visits within the past 12 months with a CDC malignant cancer condition diagnosis
**      Patient does not have conditions likely terminal for opioid prescribing present
**    Patient is not currently prescribed naloxone medications
**    Factors that increase risk for opioid overdose are present:
**      Currently receiving benzodiazepine or other central nervous system depressant medications, or
**      High opioid dosages (MME/day >= 50), or
**      History of substance use disorder, or
**      Diagnosed with sleep-disordered breathing condition
**  Then
**    Incorporate Risk Mitigation Strategies Into Opioid Therapy:
**      Order - Order naxalone
**      Document - Risk mitigation strategy implemented, snooze 3 months
**      Snooze - N/A see comment, snooze 3 months
**
*/

// META: Plan Definition: http://fhir.org/guides/cdc/opioid-cds-r4/PlanDefinition/opioid-cds-08

parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions":
  ( Common."Is Opioid Analgesic with Ambulatory Misuse Potential?"( ContextPrescriptions ) ) AmbulatoryOpioidPrescription
    where Routines."Is Subacute or Chronic Pain Prescription?"( AmbulatoryOpioidPrescription )

define "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential":
  exists( "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions" )

define "On Benzodiazepine":
  exists( Common."Active Ambulatory Benzodiazepine Rx" )

define "Total MME":
  MMECalculator.TotalMME(
    "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions"
      union Common."Active Ambulatory Opioid Rx"
  )

define "Has Substance Abuse History":
  exists (
    [Procedure: Common."Substance misuse behavioral counseling"]
  )
    or exists (
      Common."US Core-Categorized Conditions" C
        where C.code in Common."Conditions documenting substance misuse"
    )

define "Has Sleep Disordered Breathing Condition":
  exists (
    Common."US Core-Categorized Conditions" C
        where C.code in Common."Conditions Documenting Sleep Disordered Breathing"
        and C.clinicalStatus in Common."Active Condition"
  )

define "Inclusion Criteria":
  "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential"
    and Routines."Is Opioid Review Useful?"
    and (
      "On Benzodiazepine"
        or "Total MME" >= 50 '{MME}/d'
        or "Has Substance Abuse History"
        or "Has Sleep Disordered Breathing Condition"
    )

define "On Naloxone":
  exists( Common."Active Ambulatory Naloxone Rx" )

define "Exclusion Criteria":
  (
    Config."Evidence of Naloxone Enabled"
      and "On Naloxone"
  )
    or Common."End of Life Assessment"

define "Is Recommendation Applicable?":
  "Inclusion Criteria"
    and not "Exclusion Criteria"
