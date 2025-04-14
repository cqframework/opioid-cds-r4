library OpioidCDSREC11 version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSCommonConfig version '2022.1.0' called Config
include OpioidCDSRoutines version '2022.1.0' called Routines

/*
**
**  Recommendation #11
**    When prescribing opioids for subacute or chronic pain, clinicians should consider the benefits 
**    and risks of toxicology testing to assess for prescribed medications as well as other prescribed 
**    and nonprescribed controlled substances (recommendation category: B; evidence type: 4).
**
**  When
**    Provider is prescribing an opioid analgesic with ambulatory misuse potential in the outpatient setting or
**    Provider is prescribing a benzodiazepine or other central nervous system depressant medication
**    Opioid review is useful for this patient:
**      Patient is 18 or over
**      Patient does not have evidence of sickle cell disease
**      Patient does not have findings indicating limited life expectancy
**      Patient does not have orders for therapies indicating end of life care
**      Patient is not undergoing active cancer treatment:
**        Patient has had at least 2 office visits within the past 12 months with an oncology specialist present, or
**        Patient has had at least 2 office visits within the past 12 months with a CDC malignant cancer condition diagnosis
**      Patient does not have conditions likely terminal for opioid prescribing present
**    Patient prescribed opioid analgesic with ambulatory misuse potential and benzodiazepine or other central nervous system depressant medication concurrently
**  Then
**    Use particular caution when prescribing opioid pain medication and benzodiazepines concurrently:
**      Document - Will modify prescription
**      Snooze - Benefits outweigh risks, snooze 3 months
**      Snooze - N/A see comment, snooze 3 months
**
*/

// META: Plan Definition: http://fhir.org/guides/cdc/opioid-cds-r4/PlanDefinition/opioid-cds-11

parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Opioid Analgesic with Ambulatory Misuse Potential Prescriptions":
  Common."Is Opioid Analgesic with Ambulatory Misuse Potential?"( ContextPrescriptions )

define "Benzodiazepine Prescriptions":
  Common."Is Benzodiazepine?"( ContextPrescriptions )

define "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential":
  exists( "Opioid Analgesic with Ambulatory Misuse Potential Prescriptions" )

define "Patient Is Being Prescribed Benzodiazepine":
  exists( "Benzodiazepine Prescriptions" )

define "Inclusion Criteria":
  (
    (
      "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential"
        and exists Common."Active Ambulatory Benzodiazepine Rx"
    )
      or (
        "Patient Is Being Prescribed Benzodiazepine"
          and exists Common."Active Ambulatory Opioid Rx"
      )
  )
    and Routines."Is Opioid Review Useful?"

define "Exclusion Criteria":
  Common."End of Life Assessment"

define "Is Recommendation Applicable?":
  "Inclusion Criteria"
    and not "Exclusion Criteria"

define "Get Indicator":
  if "Is Recommendation Applicable?"
    then 'warning'
  else null

define "Get Summary":
  if "Is Recommendation Applicable?"
    then 'Avoid prescribing opioid pain medication and benzodiazepine concurrently whenever possible.'
  else null

define "Get Detail":
  if "Is Recommendation Applicable?"
    then
      'Consider whether the benefits outweigh the risks of concurrently prescribing opioids and benzodiazepines, or other central nervous system depressant medications.

When co-prescribing risks outweigh benefits, consult the [2022 CDC Clinical Practice Guideline Recommendation 11](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=evidence%20type%3A%203).-,Implementation%20Considerations,-Although%20in%20some) for further guidance.

[For patients being treated for opioid use disorder who are also taking benzodiazepines or other medications that depress the central nervous system, the CDC recommends not withholding buprenorphine or methadone](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=gabapentin%20and%20pregabalin).-,Buprenorphine%20or%20methadone%20for%20opioid%20use%20disorder%20should%20not%20be%20withheld%20from%20patients%20taking%20benzodiazepines%20or%20other%20medications%20that%20depress%20the%20central%20nervous%20system.,-Clinicians%20should%20check).

If the decision is made to taper benzodiazepine medications, [the CDC recommends tapering benzodiazepines gradually prior to discontinuation](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=Clinicians%20should%20taper%20benzodiazepines%20gradually%20before%20discontinuation%20because%20abrupt%20withdrawal%20can%20be%20associated%20with%20rebound%20anxiety%2C%20hallucinations%2C%20seizures%2C%20delirium%20tremens%2C%20and%2C%20rarely%2C%20death.%20The%20rate%20of%20tapering%20should%20be%20individualized).'
  else null
