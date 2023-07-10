library OpioidCDSREC04And05 version '2022.1.0'

using FHIR version '4.0.1'

include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSCommonConfig version '2022.1.0' called Config
include OpioidCDSRoutines version '2022.1.0' called Routines
// include MMECalculator version '3.0.0' called MMECalculator
include fhir.cdc."opioid-mme-r4".MMECalculator version '3.0.0' called MMECalculator

/*
**
**  Recommendation #4
**    When opioids are initiated for opioid-naïve patients with acute, subacute, or chronic pain, 
**    clinicians should prescribe the lowest effective dosage. If opioids are continued for 
**    subacute or chronic pain, clinicians should use caution when prescribing opioids at any dosage, 
**    should carefully evaluate individual benefits and risks when considering increasing dosage, and 
**    should avoid increasing dosage above levels likely to yield diminishing returns in benefits 
**    relative to risks to patients (recommendation category: A; evidence type: 3)
**  Recommendation #5
**    For patients already receiving opioid therapy, clinicians should carefully weigh benefits and 
**    risks and exercise care when changing opioid dosage. If benefits outweigh risks of continued 
**    opioid therapy, clinicians should work closely with patients to optimize nonopioid therapies 
**    while continuing opioid therapy. If benefits do not outweigh risks of continued opioid therapy, 
**    clinicians should optimize other therapies and work closely with patients to gradually taper to 
**    lower dosages or, if warranted based on the individual circumstances of the patient, appropriately 
**    taper and discontinue opioids. Unless there are indications of a life-threatening issue such as 
**    warning signs of impending overdose (e.g., confusion, sedation, or slurred speech), opioid therapy 
**    should not be discontinued abruptly, and clinicians should not rapidly reduce opioid dosages from 
**    higher dosages (recommendation category: B; evidence type: 4).
**
**  When
**    Provider is prescribing an opioid analgesic with ambulatory misuse potential in the outpatient setting
**    Opioid review is useful for this patient:
**      Patient is 18 or over
**      Patient does not have evidence of sickle cell disease
**      Patient does not have findings indicating limited life expectancy
**      Patient does not have orders for therapies indicating end of life care
**      Patient is not undergoing active cancer treatment:
**        Patient has had at least 2 office visits within the past 12 months with an oncology specialist present, or
**        Patient has had at least 2 office visits within the past 12 months with a CDC malignant cancer condition diagnosis
**      Patient does not have conditions likely terminal for opioid prescribing present
**    Patient Morphine Milligram Equivalent (MME) greater than or equal to 50
**  Then
**    Calibrate to Lowest Opioid Dose Needed for Expected Results and Exercise Care When Changing Opioid Dosages:
**      Document - Will prescribe a lower dose
**      Document - Will calibrate a gradual change in dosage
**      Snooze - Benefits outweigh risks, snooze 3 months
**      Snooze - Short term benefits outweigh risks, snooze 1 month
**      Snooze - N/A add comment, snooze 3 months
**
*/

// META: Plan Definition: http://fhir.org/guides/cdc/opioid-cds-r4/PlanDefinition/opioid-cds-04-05

parameter ContextPrescriptions List<MedicationRequest>

context Patient

// define "Taper Now": "Total MME".value >= 90

// define "Consider Tapering": "Total MME".value < 90

define "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions":
  ( Common."Is Opioid Analgesic with Ambulatory Misuse Potential?"( ContextPrescriptions ) ) AmbulatoryOpioidPrescription
    where Routines."Is Subacute or Chronic Pain Prescription?"( AmbulatoryOpioidPrescription )

define "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential":
  exists( "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions" )

define "Total MME":
  MMECalculator.TotalMME(
    (
      "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions"
        union Common."Active Ambulatory Opioid Rx"
    ) AmbulatoryOpioidPrescription
      where Routines."Is Subacute or Chronic Pain Prescription?"( AmbulatoryOpioidPrescription )
  )

define "Inclusion Criteria":
  "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential"
    and Routines."Is Opioid Review Useful?"
    and "Total MME" >= 50 '{MME}/d'

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
    then
      'Calibrate to Lowest Opioid Dose Needed for Expected Results and Exercise Care When Changing Opioid Dosages'
  else null

define "Get Detail":
  if "Is Recommendation Applicable?"
    then
    'When opioid therapy is considered appropriate, calibrate opioid dosages to lowest dose needed to achieve expected effects. For patients already receiving opioid therapy, clinicians should carefully weigh benefits and risks and exercise care when changing opioid dosage.

[For guidance in determining the lowest effective opioid dosage, see Recommendation 4 of the 2022 CDC Clinical Practice Guideline](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=lowest%20effective%20dosage.-,For%20patients%20not%20already%20taking%20opioids%2C%20the%20lowest%20effective%20dose%20can,intended%20to%20be%20guideposts%20to%20help%20inform%20clinician%2Dpatient%20decision%2Dmaking.,-Supporting%20Rationale)

[For patients who have received opioid therapy for longer durations of time, if tapering, consider working closely with the patient to gradually taper dosages (no more than 10% per month)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=When%20patients%20have%20been%20taking%20opioids%20for%20longer%20durations%20(e.g.%2C%20for%20%E2%89%A51%20year)%2C%20tapers%20of%2010%25%20per%20month%20or%20slower%20are%20likely%20to%20be%20better%20tolerated%20than%20more%20rapid%20tapers.)

For a tapering calculator, go to [https://agencymeddirectors.wa.gov/Calculator/TaperDoseCalculator.html](https://www.agencymeddirectors.wa.gov/Calculator/TaperDoseCalculator.html)

[For more guidance regarding tapering, please see Recommendation 5 of the 2022 CDC Clinical Practice Guideline for Prescribing Opioids for Pain](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=When%20benefits%20(including,6%20and%207).)

**MME Calculator Cautions**
1) All doses are in mg/day except for fentanyl, which is mcg/hr. 
2) Equianalgesic dose conversions are only estimates and cannot account for individual variability in genetics and pharmacokinetics. 
3) Do not use the calculated dose in MMEs to determine the doses to use when converting one opioid to another; when converting opioids, the new opioid is typically dosed at a substantially lower dose than the calculated MME dose to avoid overdose because of incomplete cross-tolerance and individual variability in opioid pharmacokinetics. Consult the FDA approved product labeling for specific guidance on medications. 
4) Use particular caution with methadone dose conversions because methadone has a long and variable half-life, and peak respiratory depressant effect occurs later and lasts longer than peak analgesic effect. 
5) Use particular caution with transdermal fentanyl because it is dosed in mcg/hr instead of mg/day, and its absorption is affected by heat and other factors. 
6) Buprenorphine products approved for the treatment of pain are not included in the table because of their partial µ-receptor agonist activity and resultant ceiling effects compared with full µ-receptor agonists. 
7) These conversion factors should not be applied to dosage decisions related to the management of opioid use disorder.
† Tapentadol is a µ-receptor agonist and norepinephrine reuptake inhibitor. MMEs are based on degree of µ-receptor agonist activity; however, it is unknown whether tapentadol is associated with overdose in the same dose-dependent manner as observed with medications that are solely µ-receptor agonists.
§ Tramadol is a µ-receptor agonist and norepinephrine and serotonin reuptake inhibitor. MMEs are based on degree of µ-receptor agonist activity; however, it is unknown whether tramadol is associated with overdose in the same dose-dependent manner as observed with medications that are solely µ-receptor agonists.'
  else null
