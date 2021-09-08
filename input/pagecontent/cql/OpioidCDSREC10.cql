library OpioidCDSREC10 version '2.0.1'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2.0.1' called Common
include OpioidCDSCommonConfig version '2.0.1' called Config
include OpioidCDSRoutines version '2.0.1' called Routines

/*
**  Recommendation #10
**    When prescribing opioids for chronic pain, providers should use urine drug
**    testing before starting opioid therapy and consider urine drug testing at
**    least annually to assess for prescribed medications as well as other controlled
**    prescription drugs and illicit drugs (recommendation category: B, evidence type: 4)
**
**  When
**    Provider is prescribing an opioid analgesic with ambulatory misuse potential in the outpatient setting
**    Prescription is for treating chronic pain.
**    Opioid review is useful for this patient:
**      Patient is 18 or over
**      Patient does not have findings indicating limited life expectancy
**      Patient does not have orders for therapies indicating end of life care
**      Patient is not undergoing active cancer treatment:
**        Patient has had at least 2 encounters within the past year with any diagnosis of cancer
**    Urine drug screening has not been performed in last 12 months
**  Then
**    Recommend urine drug screening
**      Will perform urine screening
**      Not for chronic pain management, snooze 3 months
**      N/A - see comment, snooze 3 months
**
*/

// META: Plan Definition: http://fhir.org/guides/cdc/opioid-cds-r4/PlanDefinition/opioid-cds-10

parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Lookback Year":
  Interval[Today() - 12 months - 1 days, Today() - 1 day]

define "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions":
  ( Common."Is Opioid Analgesic with Ambulatory Misuse Potential?"( ContextPrescriptions ) ) AmbulatoryOpioidPrescription
    where Routines."Is Chronic Pain Prescription?"( AmbulatoryOpioidPrescription )

define "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential":
  exists( "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions" )

define "Is Recommendation Applicable?":
  "Inclusion Criteria"
    and not "Exclusion Criteria"

define "Patient Age Less Than 18":
  if (Config."Age Less than 18 Years Is Enabled") then
    AgeInYearsAt(Today()) < 18
  else
    false

define "Inclusion Criteria":
  "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential"
    and not "Patient Age Less Than 18"
    and Routines."Is Opioid Review Useful?"
    and not "Patient had Urine Screening in Last 12 Months"

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "Patient had Urine Screening in Last 12 Months":
  exists( "Urine Screenings during the Last 12 Months" )

define "Urine Screenings during the Last 12 Months":
  "Non-opioid Screenings"
    union "Opioid Screenings"
    union "Cocaine Screenings"
    union "PCP Screenings"

define "Laboratory Observations":
    [Observation: "category" in Common."Observation Category Laboratory"]

define "Non-opioid Screenings":
  GetRelevantScreenings("Laboratory Observations" LabObservations
      where (LabObservations.code in Common."Non-opioid drug urine screening")
  )

define "Opioid Screenings":
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

define function GetRelevantScreenings(obsList List<Observation>):
  obsList LabObservations
     where date from LabObservations.effective in day of "Lookback Year"
       and not (LabObservations.status.value in { 'unknown', 'entered-in-error', 'cancelled' })

define "No Screening In Last 12 Months Indicator":
  if "Is Recommendation Applicable?"
    then 'warning'
  else null

define "No Screening In Last 12 Months Summary":
  if "Is Recommendation Applicable?"
    then 'Annual Urine Screening Check'
  else null

define "No Screening In Last 12 Months Detail":
  if "Is Recommendation Applicable?"
    then 'Patients on opioid therapy should have a urine drug test performed every 12 months.'
  else null
