library OpioidCDSREC01 version '2022.1.0'

using FHIR version '4.0.1'

include fhir.cqf.common.FHIRHelpers version '4.0.1' called FHIRHelpers
include OpioidCDSCommon version '2022.1.0' called Common
include OpioidCDSCommonConfig version '2022.1.0' called Config
include OpioidCDSRoutines version '2022.1.0' called Routines

/*
**
**  Recommendation #1
**    Nonopioid therapies are at least as effective as opioids for many common types of acute pain. 
**    Clinicians should maximize use of nonpharmacologic and nonopioid pharmacologic therapies as 
**    appropriate for the specific condition and patient and only consider opioid therapy for acute 
**    pain if benefits are anticipated to outweigh risks to the patient. Before prescribing opioid 
**    therapy for acute pain, clinicians should discuss with patients the realistic benefits and 
**    known risks of opioid therapy (recommendation category: B; evidence type: 3).
**
**  When
**    Provider is prescribing an opioid analgesic with ambulatory misuse potential in the outpatient setting
**    Prescription is for treating acute pain.
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
**  Then
**    Consider Nonopioid Treatment Options for Acute Pain:
**      Document - Record reason for opioid therapy
**      Snooze - Attempt alternative therapy, snooze 3 months
**      Order - Select alternative therapies from order set
**      Snooze - N/A see comment, snooze 3 months
**      Remove - Will remove triggering medication order
**
*/

// META: Plan Definition: http://fhir.org/guides/cdc/opioid-cds-r4/PlanDefinition/opioid-cds-01

parameter ContextPrescriptions List<FHIR.MedicationRequest>

context Patient

define "Acute Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions":
  ( Common."Is Opioid Analgesic with Ambulatory Misuse Potential?"( ContextPrescriptions ) ) AmbulatoryOpioidPrescription
    where Routines."Is Acute Pain Prescription?"( AmbulatoryOpioidPrescription )

define "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential":
  exists( "Acute Pain Opioid Analgesic with Ambulatory Misuse Potential Prescriptions" )

define "Inclusion Criteria":
  "Patient Is Being Prescribed Opioid Analgesic with Ambulatory Misuse Potential"
    and Routines."Is Opioid Review Useful?"
    and Routines."Is Opioid Naive?"

define "Exclusion Criteria":
  false

define "Is Recommendation Applicable?":
  "Inclusion Criteria"
    and not "Exclusion Criteria"

define "Get Indicator":
  if "Is Recommendation Applicable?"
    then 'warning'
  else null

define "Get Summary":
  if "Is Recommendation Applicable?"
    then 'Consider Nonopioid Treatment Options for Acute Pain'
  else null

define "Get Detail":
  if "Is Recommendation Applicable?"
  then 
    'For many types of acute pain, clinicians should maximize the use of nonpharmacologic (for example, physical therapy) and nonopioid pharmacologic therapies (for example, NSAIDs), as appropriate for the specific condition and patient and only consider opioid therapy for acute pain if benefits are anticipated to outweigh risks to the patient. Before prescribing opioid therapy for acute pain, clinicians should discuss with patients the realistic benefits and known risks of opioid therapy.

The 2022 CDC Clinical Practice Guideline Recommendation #1 provides recommendations for non-opioid therapy options for common pain conditions.

**Nonopioid Pharmacological Therapy**
- [Dental pain (acute)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=The%20American%20Dental%20Association%20(ADA)%20recommends%20NSAIDs%20as%20first%2Dline%20treatment%20for%20acute%20dental%20pain%20management)
- [Dental pain (surgical)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=NSAIDs%20have%20been%20found%20to%20be%20more%20effective%20than%20opioids%20for%20surgical%20dental%20pain)
- [Kidney stone pain (acute)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=For%20acute%20kidney%20stone%20pain%2C%20NSAIDs%20are%20at%20least%20as%20effective%20as%20opioids%20(124%E2%80%93127)%2C%20can%20decrease%20the%20ureteral%20smooth%20muscle%20tone%20and%20ureteral%20spasm%20(128)%20causing%20kidney%20stone%20pain%2C%20and%20are%20preferred%20for%20kidney%20stone%20pain%20if%20not%20contraindicated.)
- [Low back pain (acute)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=NSAIDs%20have%20been%20found%20to%20be%20more%20effective%20than%20opioids%20for%20surgical%20dental%20pain%20and%20kidney%20stone%20pain%20and%20similarly%20effective%20to%20opioids%20for%20low%20back%20pain)
- [Migraine pain (episodic)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=For%20episodic%20migraine%2C%20triptans%2C%20NSAIDs%2C%20antiemetics%2C%20dihydroergotamine%2C%20calcitonin%20gene%2Drelated%20peptide%20antagonists%20(gepants)%2C%20and%20lasmiditan%20are%20associated%20with%20improved%20pain%20and%20function%20with%20usually%20mild%20and%20transient%20adverse%20events)
- [Musculoskeletal pain](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=A%20systematic%20review%20found%20that%20for%20musculoskeletal%20injuries%20such%20as%20sprains%2C%20whiplash%2C%20and%20muscle%20strains%2C%20topical%20NSAIDs%20provided%20the%20greatest%20benefit%2Dharm%20ratio%2C%20followed%20by%20oral%20NSAIDs%20or%20acetaminophen%20with%20or%20without%20diclofenac)
- [Postpartum pain](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=Pain%20Management%20for%20Pregnant%20and%20Postpartum%20Persons)

**Nonpharmacologic Treatments**
- [Back pain (acute)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=The%20American%20College%20of%20Physicians%20(ACP)%20recommends%20nonpharmacologic%20treatment%20with%20superficial%20heat%2C%20massage%2C%20acupuncture%2C%20or%20spinal%20manipulation%20as%20a%20cornerstone%20of%20treatment%20for%20acute%20low%20back%20pain)
- [Migraine pain (episodic)](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=remote%20electrical%20neuromodulation%20for%20acute%20pain%20related%20to%20episodic%20migraine)
- [Musculoskeletal pain](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=acupressure%20for%20acute%20musculoskeletal%20pain)
- [Postoperative pain](https://www.cdc.gov/mmwr/volumes/71/rr/rr7103a1.htm?s_cid=rr7103a1_w#:~:text=massage%20for%20postoperative%20pain)'
  else null
