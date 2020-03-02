library ChronicPainDecisionPoints version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common

context Patient

define "Previous 10 Days Interval":
Interval[Today() - 10 days, Today()]

define "First Month":
Interval[Today() - 3 months, Today() - 2 months]

define "Second Month":
Interval[Today() - 2 months, Today() - 1 months]

define "Third Month":
Interval[Today() - 1 months, Today()]

/*

  A patient is considered chronically on opioids if they have been on opioids for either:
    - 7 or more of the past 10 days with an encounter
    - 21 or more of 30 days for each of the past 3 month

*/
define "Chronically on Opioids":
  "Prescribed Opioids for 7 of Past 10 Days with an Encounter"
    and "Prescribed Opioids for 21 or more of 30 Days for each of the past 3 Months"

define "Prescribed Opioids for 7 of Past 10 Days with an Encounter":
  exists (
    [Encounter: Common."All Ambulatory Encounters"] AmbulatoryEncounter
      where AmbulatoryEncounter.period during "Previous 10 Days Interval"
        and "Days on Opioids during Period"( "Previous 10 Days Interval" ) >= 7
  )

define "Prescribed Opioids for 21 or more of 30 Days for each of the past 3 Months":
  "Days on Opioids during Period"( "First Month" ) >= 21
    and "Days on Opioids during Period"( "Second Month" ) >= 21
    and "Days on Opioids during Period"( "Third Month" ) >= 21

define function "Prescription Relevant Period"(prescription FHIR.MedicationRequest):
  if (
    prescription.authoredOn is not null and prescription.dispenseRequest is not null
      and prescription.dispenseRequest.expectedSupplyDuration is not null
  )
  then Interval[
    date from prescription.authoredOn,
    date from prescription.authoredOn + System.Quantity{ value: Common.GetDurationInDays( prescription.dispenseRequest.expectedSupplyDuration ), unit: 'd' }
  ]
  else null

define function "Days on Opioids during Period"(period Interval<Date>):
  Sum(
    (
      collapse (
        [MedicationRequest: Common."Opioids With Ambulatory Misuse Potential"] OpioidPrescription
        return "Prescription Relevant Period"( OpioidPrescription ) intersect period
      )
    ) OpioidUseInterval
      return days between start of OpioidUseInterval and end of OpioidUseInterval
  )

/*

  A medication is considered for chronic pain if it is being prescribed for
    28 days or more or the patient is chronically on opioids

*/
define function "Chronic Pain Prescription"(prescription FHIR.MedicationRequest):
  (
    prescription.dispenseRequest is not null
      and prescription.dispenseRequest.expectedSupplyDuration is not null
      and Common.GetDurationInDays( prescription.dispenseRequest.expectedSupplyDuration ) >= 28
  )
  or "Chronically on Opioids"

/*

  A medication is considered for acute pain if it is being prescribed for less
    than 28 days or the patient is not chronically on opioids

*/
define function "Acute Pain Prescription"(prescription FHIR.MedicationRequest):
  (
    prescription.dispenseRequest is not null
      and prescription.dispenseRequest.expectedSupplyDuration is not null
      and Common.GetDurationInDays( prescription.dispenseRequest.expectedSupplyDuration ) < 28
  )
  or not "Chronically on Opioids"
