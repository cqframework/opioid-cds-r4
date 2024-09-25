library OpioidCDSREC10OrderSignCRD version '2022.1.0'

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1' called FHIRHelpers

/*
**  Recommendation #10
**    When prescribing opioids for subacute or chronic pain, clinicians should consider the benefits 
**    and risks of toxicology testing to assess for prescribed medications as well as other prescribed 
**    and nonprescribed controlled substances (recommendation category: B; evidence type: 4).
**
**  When
**    Provider is prescribing an opioid analgesic with ambulatory misuse potential in the outpatient setting:
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
**    Nonopioid drug urine screening has not been performed in last 12 months or
**    Opioid drug urine screening has not been performed in last 12 months
**  Then
**    Consider the benefits and risks of conducting a urine toxicology screen:
**      Document - Order toxicology screen
**      Document risks outweigh benefits
**      Snooze - N/A see comment, snooze 3 months
**  When
**    Provider is prescribing an opioid analgesic with ambulatory misuse potential in the outpatient setting:
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
**    Nonopioid drug urine screening has been performed in last 12 months and
**    Opioid drug urine screening has been performed in last 12 months and
**    Positive result for synthetic opioid in the past year and not currently prescribed synthetic opioid or
**    Positive result for phencyclidine(PCP) in the past year or
**    Positive result for fentanyl in the past year and not currently prescribed fentanyl or
**    Positive result for cocaine in the past year or
**    Positive result for amphetamine in the past year and not currently prescribed amphetamine or
**    Positive result for tetrahydrocannabinol (THC) in the past year and not currently prescribed tetrahydrocannabinol (THC) or
**    Positive result for opiate in the past year and not currently prescribed natural opiate or
**    Positive result for alcohol in the past year or
**    Positive result for methadone in the past year and not currently prescribed methadone
**  Then
**    Patient may have unexpected toxicology test results:
**      Document - Will repeat urine drug screening more frequently
**      Document - Will assess patient for substance use disorder
**      Snooze - Patient's test results were expected, snooze for 3 months
**      Snooze - N/A snooze for 3 months
**
*/

// META: Plan Definition: http://fhir.org/guides/cdc/opioid-cds-r4/PlanDefinition/opioid-cds-10-order-sign

parameter ContextPrescriptions List<MedicationRequest>

context Patient

define "Do the CRD thing?": true

define "Get Coverage Extension":
  FHIR.Extension {
    url: FHIR.url { value: 'http://hl7.org/fhir/us/davinci-crd/StructureDefinition/ext-coverage-information' },
    extension: {
        FHIR.Extension {
        url: FHIR.url { value: 'coverage' },
        value: FHIR.Reference {
          reference: FHIR.string { value: 'http://example.org/fhir/Coverage/example' }
        }
      },
      FHIR.Extension {
        url: FHIR.url { value: 'covered' },
        value: FHIR.code { value: 'covered' }
      },
      FHIR.Extension {
        url: FHIR.url { value: 'pa-needed' },
        value: FHIR.code { value: 'satisfied' }
      },
      FHIR.Extension {
        url: FHIR.url { value: 'billingCode' },
        value: FHIR.Coding { 
          system: FHIR.uri { value: 'http://www.ama-assn.org/go/cpt' },
          code: FHIR.code { value: '77065' } 
        }
      },
      FHIR.Extension {
        url: FHIR.url { value: 'billingCode' },
        value: FHIR.Coding { 
          system: FHIR.uri { value: 'http://www.ama-assn.org/go/cpt' },
          code: FHIR.code { value: '77066' } 
        }
      },
      FHIR.Extension {
        url: FHIR.url { value: 'billingCode' },
        value: FHIR.Coding { 
          system: FHIR.uri { value: 'http://www.ama-assn.org/go/cpt' },
          code: FHIR.code { value: '77067' } 
        }
      },
      FHIR.Extension {
        url: FHIR.url { value: 'reason' },
        value: FHIR.CodeableConcept { text: FHIR.string { value: 'In-network required unless exigent circumstances' } }
      }   
    }
  }
