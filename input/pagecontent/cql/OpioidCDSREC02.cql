library OpioidCDSREC02 version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSCommonConfig version '2022.1.0' called Config
include OpioidCDSRoutines version '2022.1.0' called Routines

/*
**
**  Recommendation #2
**    Nonopioid therapies are preferred for subacute and chronic pain. Clinicians should maximize 
**    use of nonpharmacologic and nonopioid pharmacologic therapies as appropriate for the specific 
**    condition and patient and only consider initiating opioid therapy if expected benefits for 
**    pain and function are anticipated to outweigh risks to the patient. Before starting opioid 
**    therapy for subacute or chronic pain, clinicians should discuss with patients the realistic 
**    benefits and known risks of opioid therapy, should work with patients to establish treatment 
**    goals for pain and function, and should consider how opioid therapy will be discontinued if 
**    benefits do not outweigh risks (recommendation category: A; evidence type: 2).
**
**  When
**    Provider is prescribing an opioid with ambulatory misuse potential in the outpatient setting
**    Prescription is for treating subacute and/or chronic pain.
**    Opioid review is useful for this patient:
**      Patient is 18 or over
**      Patient does not have evidence of sickle cell disease
**      Patient does not have findings indicating limited life expectancy
**      Patient does not have orders for therapies indicating end of life care
**      Patient is not undergoing active cancer treatment:
**        Patient has had at least 2 office visits within the past 12 months with an oncology specialist present, or
**        Patient has had at least 2 office visits within the past 12 months with a CDC malignant cancer condition diagnosis
**      Patient does not have conditions likely terminal for opioid prescribing present
**    Patient is opioid naive:
**      No indication of opioid use in the past 90 days from a prescription, self report (for future implementation), or a dispensing event (for future implementation)
**    Pain management procedure in past 90 days is not present and
**    Pain treatment plan created, edited, or reviewed by the prescribing physician in past 90 days is not present
**  Then
**    Maximize Nonopioid Therapies as Appropriate:
**      Document - Collaborated with patient to identify treatment goals
**      Snooze - Attempting alternate therapy, snooze 3 months
**      Order - Select alternative therapies from order select
**      Snooze - N/A see comment, snooze 3 months
**      Remove - Will remove triggering medication order
**
*/

// META: PlanDefinition: http://fhir.org/guides/cdc/opioid-cds-r4/PlanDefinition/opioid-cds-02

parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Treatment Plan Lookback Period":
  Interval[Today() - 90 days, Today()]

define "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions":
  ( Common."Is Opioid Analgesic with Ambulatory Misuse Potential?"( ContextPrescriptions ) ) AmbulatoryOpioidPrescription
    where Routines."Is Subacute or Chronic Pain Prescription?"( AmbulatoryOpioidPrescription )

define "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential":
  exists( "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions" )

define "No Opioid Treatment Plan Created, was Edited or Reviewed in Past 90 Days?":
  Config."Opioid Treatment Plan Verification Enabled"
    and not (
      exists ( "Opioid Treatment Plan Creation or Update in Past 90 Days" )
        or "Had Opioid Treatment Plan Reviewed in Past 90 Days"
    )

define "Opioid Treatment Plan Creation or Update in Past 90 Days":
  [CarePlan: category in Common."Pain Treatment Plan"] PainTreatmentPlan
    where PainTreatmentPlan.status in { 'active', 'completed' }
      and (
        FHIRHelpers.ToDateTime( PainTreatmentPlan.created ) during day of "Treatment Plan Lookback Period"
          or PainTreatmentPlan.meta.lastUpdated during day of "Treatment Plan Lookback Period"
      )
      and exists(
        "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions".recorder Recorder
          where Recorder ~ PainTreatmentPlan.author
      )

define "Had Opioid Treatment Plan Reviewed in Past 90 Days":
  exists (
    [Procedure: Common."Pain Management Procedure"] PainManagementProcedure
      where PainManagementProcedure.performed during day of "Treatment Plan Lookback Period"
        and exists (
          PainManagementProcedure.performer Performer
            with "Chronic Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions" ChronicPainScript
            such that Performer.actor ~ ChronicPainScript.recorder
        )
  )

define "Inclusion Criteria":
  "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential"
    and Routines."Is Opioid Review Useful?"
    and Routines."Is Opioid Naive?"
    and "No Opioid Treatment Plan Created, was Edited or Reviewed in Past 90 Days?"

define "Is Recommendation Applicable?":
  "Inclusion Criteria"

define "Get Indicator":
  if "Is Recommendation Applicable?"
    then 'warning'
  else null

define "Get Summary":
  if "Is Recommendation Applicable?"
    then 'Maximize Nonopioid Therapies as Appropriate'
  else null

define "Get Detail":
  if "Is Recommendation Applicable?"
  then 
    'For many types of subacute and chronic pain, consider maximizing the use of nonpharmacologic and nonopioid pharmacologic therapies as appropriate. Consult Recommendation 2 of the 2022 CDC Clinical Practice Guideline for nonopioid therapy recommendations.
    
**Nonopioid Pharmacological Therapy**

- [Back pain (chronic, moderate to severe)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=For%20moderate%20to%20severe%20chronic%20back%20pain%20or%20hip%20or%20knee%20osteoarthritis%20pain%2C%20a%20nonopioid%20strategy%20starting%20with%20acetaminophen%20or%20NSAIDs%20results%20in%20improved%20pain%20intensity%20with%20fewer%20side%20effects%20compared%20with%20a%20strategy%20starting%20with%20opioids%20(74))
- [Fibromyalgia](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=In%20patients%20with%20fibromyalgia%2C%20multiple,effectiveness%20is%20limited%20(8).)
- [Hip or knee osteoarthritis pain (chronic)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=or%20hip%20or%20knee%20osteoarthritis%20pain%2C%20a%20nonopioid%20strategy%20starting%20with%20acetaminophen%20or%20NSAIDs%20results%20in%20improved%20pain%20intensity%20with%20fewer%20side%20effects%20compared%20with%20a%20strategy%20starting%20with%20opioids%20(74).)
- [Neuropathic pain syndromes](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=Tricyclic%20antidepressants%2C%20SNRI%20antidepressants%2C%20selected%20anticonvulsants%2C%20or%20transdermal%20lidocaine%20are%20recommended%20for%20neuropathic%20pain%20syndromes%20(e.g.%2C%20diabetic%20neuropathy%20or%20postherpetic%20neuralgia)%20(156).)
- [Temporomandibular disorder](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=For%20temporomandibular%20disorder%20pain%20that%20is%20not%20sufficiently%20improved%20with%20nonpharmacologic%20interventions%2C%20NSAIDs%20can%20be%20effective%20(179%2C180).)

**Nonpharmacologic Treatments**
- [Back pain (chronic)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=Clinicians%20should%20recommend%20appropriate%20noninvasive%20nonpharmacologic%20approaches%20to%20help%20manage%20chronic%20pain%2C%20such%20as%20exercise%20(e.g.%2C%20aerobic%2C%20aquatic%2C%20or%20resistance%20exercises)%20or%20exercise%20therapy%20(a%20prominent%20modality%20in%20physical%20therapy)%20for%20back%20pain)
- [Back pain (low back, chronic)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=loss%20for%20knee%20osteoarthritis%3B%20manual%20therapies%20for%20hip%20osteoarthritis%3B-,psychological%20therapy%2C%20spinal%20manipulation%2C%20low%2Dlevel%20laser%20therapy%2C%20massage%2C%20mindfulness%2Dbased%20stress%20reduction%2C%20yoga%2C%20acupuncture%2C%20and%20multidisciplinary%20rehabilitation%20for%20low%20back%20pain,-%3B%20mind%2Dbody%20practices%20(e.g.%2C%20yoga%2C%20tai%20chi%2C%20or)
- [Fibromyalgia](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=massage%2C%20and%20acupuncture%20for%20neck%20pain%3B%20cognitive-,behavioral%20therapy%2C%20myofascial%20release%20massage%2C%20mindfulness%20practices%2C%20tai%20chi%2C%20qigong%2C%20acupuncture%2C%20and%20multidisciplinary%20rehabilitation%20for%20fibromyalgia,-%3B%20and%20spinal%20manipulation%20for%20tension%20headache%20()
- [Headache (tension)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=and%20spinal%20manipulation%20for%20tension%20headache.)
- [Knee osteoarthritis pain (chronic)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=Many%20noninvasive%20nonpharmacologic,for%20hip%20osteoarthritis%3B)
- [Neck pain](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=mind%2Dbody%20practices%20(e.g.%2C%20yoga%2C%20tai%20chi%2C%20or%20qigong)%2C%20massage%2C%20and%20acupuncture%20for%20neck%20pain%3B)
- [Temporomandibular disorder](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm#:~:text=For%20temporomandibular%20disorder%20pain%2C%20patient%20education%20and%20self%2Dcare%20can%20be%20effective%2C%20as%20can%20occlusal%20splints%20for%20some%20patients%20and%20biobehavioral%20therapy%20for%20prevention%20of%20disabling%20symptoms%20(172%2C173).)'
  else null
