library OpioidCDS_Common version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OMTKLogic version '0.0.3' called OMTKLogic

codesystem "LOINC": 'http://loinc.org'
codesystem "SNOMED": 'http://snomed.info/sct'
codesystem "Medication Request Category Codes": 'http://terminology.hl7.org/CodeSystem/medicationrequest-category'
codesystem "Condition Clinical Status Codes": 'http://terminology.hl7.org/CodeSystem/condition-clinical'

// Expression-based
valueset "Opioid analgesics with ambulatory misuse potential": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/opioid-analgesics-with-ambulatory-misuse-potential'
valueset "Extended release opioid analgesics with ambulatory misuse potential": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/extended-release-opioids-with-ambulatory-misuse-potential'
valueset "Buprenorphine and methadone medications": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/buprenorphine-and-methadone-medications'

// Enumerated-compose
valueset "Limited life expectancy conditions": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/limited-life-expectancy-conditions-enum'
valueset "Therapies indicating end of life care": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/therapies-indicating-end-of-life-care-enum'
valueset "Conditions likely terminal for opioid prescribing": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/conditions-likely-terminal-for-opioid-prescribing-enum'
valueset "CDC malignant cancer conditions": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/cdc-malignant-cancer-conditions-enum'
valueset "Oncology specialty designations (NUCC)": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/oncology-specialty-designations-enum'
valueset "Opioid misuse disorders": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/opioid-misuse-disorders-enum'
valueset "Substance misuse behavioral counseling": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/substance-misuse-behavioral-counseling-enum'
valueset "Office Visit": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/office-visit' // Harvested from VSAC - OID: 2.16.840.1.113883.3.464.1003.101.12.1001

/* Existing sets for first six recs */
valueset "Benzodiazepine medications": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/benzodiazepine-medications'
valueset "Non-opioid illicit drug urine screening": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/non-opioid-illicit-drug-urine-screening'
valueset "Naloxone medications": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/naloxone-medications'
valueset "Opioid misuse assessment procedure": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/opioid-misuse-assessment-procedure'
valueset "Opioid drug urine screening": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/opioid-drug-urine-screening'
valueset "Substance misuse behavioral counseling": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/substance-misuse-behavioral-counseling'
valueset "Hospice Disposition": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/hospice-disposition' // Harvested from VSAC - OID: 2.16.840.1.113762.1.4.1108.15
valueset "Hospice Finding Codes": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/hospice-finding'
valueset "Hospice Procedure Codes": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/hospice-procedure'

valueset "Pain treatment plan": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/pain-treatment-plan'
valueset "Pain management procedure": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/pain-management-procedure'
valueset "PDMP review procedure": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/pdmp-review-procedure'
valueset "PDMP data reviewed finding": 'http://fhir.org/guides/cdc/opioid-cds/ValueSet/pdmp-data-reviewed-finding'

// Recommendation #2
// See the latest notes in the Definitions table for Rec 2 - needs to be specific Direct Reference Codes:
//  Creation: Opioid treatment plan: LOINC 80764-4 Pain medicine plan of care note
//  Edit/Review: Treatment Plan Edited or Reviewed: SNOMED Chronic pain control management (procedure) 408957008
valueset "Pain Management Treatment Plan Review": 'http://todo.com/pain-management-treatment-plan-review'

/*
Opioid treatment plan exists (a record artifact)	 #2      80764-4 Pain medicine Plan of care note
Opioid treatment plan edited (a procedure)	         #2      Chronic pain control management (procedure) SCTID: 408957008
Opioid treatment plan reviewed (a procedure if to be an order, a finding if identifying it has occurred)	#2 Chronic pain control management (procedure) SCTID: 408957008
Documented discussion of opioid harms and risks	     #3      Counseling about opioid safety (procedure) 460831000124102
Documented discussion of opioid harms and risks	     #3      Exclusion for rec #3 - Counseling about opioid safety not done (situation) SCTID: 460841000124107
Review PDMP data procedure	#9   Review of prescription drug monitoring program record (procedure) SCTID: 461621000124108
PDMP data review done Situation (the finding/situation is documented)	#9    Review of prescription drug monitoring program record done (situation) SCTID: 461651000124104
*/
// NOTE: Direct-reference code identifiers have to be the name of the code in the code system, we can't rename codes
// NOTE: Need tooling to support enforcing this fact
// NOTE: These direct reference codes will all be turned in to value sets based on implementation feedback that direct-reference codes are more difficult to map
code "Opioid treatment plan exists (a record artifact)": '80764-4' from "LOINC" //Pain medicine Plan of care note
code "Opioid treatment plan edited (a procedure)": '408957008' from "SNOMED" //Chronic pain control management (procedure) SCTID: 408957008
code "Opioid treatment plan reviewed (a procedure if to be an order, a finding if identifying it has occurred)": '408957008' from "SNOMED" //Chronic pain control management (procedure) SCTID: 408957008
code "Documented discussion of opioid harms and risks": '460831000124102' from "SNOMED" //Counseling about opioid safety (procedure)
code "Documented discussion of opioid harms and risks not done": '460841000124107' from "SNOMED" //Counseling about opioid safety not done (situation)
code "Review PDMP data procedure": '461621000124108' from "SNOMED" //Review of prescription drug monitoring program record (procedure)
code "PDMP data review done Situation (the finding/situation is documented)": '461651000124104' from "SNOMED" //Review of prescription drug monitoring program record done (situation)

code "Referral to Hospice": '306205009' from "SNOMED"
code "Outpatient": 'outpatient' from "Medication Request Category Codes"
code "Active Condition": 'active' from "Condition Clinical Status Codes"

// TODO: code "Nonpharmacologic therapy and nonopioid pharmocologic": 'TODO' from "TODO"

// TODO: Capture process decisions for long-term opioid use
define IsForChronicPain: true

define "Active Ambulatory Opioid Rx":
  (
    "Get Active Ambulatory Medication Requests"([MedicationRequest: "Opioid analgesics with ambulatory misuse potential"])
  )
    union
    (
        ("Get Active Ambulatory Medication Requests"([MedicationRequest])) Rx
          let Med: [Medication: id in (Last(Split(Rx.medication.reference, '/')))]
          where Med.code in "Opioid analgesics with ambulatory misuse potential"
          return
            MedicationRequest {
              id: Rx.id,
              status: Rx.status,
              intent: Rx.intent,
              category: Rx.category,
              medication: First(Med.code),
              subject: Rx.subject,
              recorder: Rx.recorder,
              dosageInstruction: Rx.dosageInstruction,
              dispenseRequest: Rx.dispenseRequest
            }
    )


define "Active Ambulatory Benzodiazepine Rx":
  (
    "Get Active Ambulatory Medication Requests"([MedicationRequest: "Benzodiazepine medications"])
  )
    union
    (
        ("Get Active Ambulatory Medication Requests"([MedicationRequest])) Rx
          let Med: [Medication: id in (Last(Split(Rx.medication.reference, '/')))]
          where Med.code in "Benzodiazepine medications"
          return
            MedicationRequest {
              id: Rx.id,
              status: Rx.status,
              intent: Rx.intent,
              category: Rx.category,
              medication: First(Med.code),
              subject: Rx.subject,
              recorder: Rx.recorder,
              dosageInstruction: Rx.dosageInstruction,
              dispenseRequest: Rx.dispenseRequest
            }
    )

define "Active Ambulatory Naloxone Rx":
  (
    "Get Active Ambulatory Medication Requests"([MedicationRequest: "Naloxone medications"])
  )
    union
    (
        ("Get Active Ambulatory Medication Requests"([MedicationRequest])) Rx
          let Med: [Medication: id in (Last(Split(Rx.medication.reference, '/')))]
          where Med.code in "Naloxone medications"
          return
            MedicationRequest {
              id: Rx.id,
              status: Rx.status,
              intent: Rx.intent,
              category: Rx.category,
              medication: First(Med.code),
              subject: Rx.subject,
              recorder: Rx.recorder,
              dosageInstruction: Rx.dosageInstruction,
              dispenseRequest: Rx.dispenseRequest
            }
    )

define "Ambulatory Opioid Rx":
  (
    "Get Active Ambulatory Medication Requests"([MedicationRequest: "Opioid analgesics with ambulatory misuse potential"])
  )
    union
    (
        ("Get Active Ambulatory Medication Requests"([MedicationRequest])) Rx
          let Med: [Medication: id in (Last(Split(Rx.medication.reference, '/')))]
          where Med.code in "Opioid analgesics with ambulatory misuse potential"
          return
            MedicationRequest {
              id: Rx.id,
              status: Rx.status,
              intent: Rx.intent,
              category: Rx.category,
              medication: First(Med.code),
              subject: Rx.subject,
              recorder: Rx.recorder,
              dosageInstruction: Rx.dosageInstruction,
              dispenseRequest: Rx.dispenseRequest
            }
    )

define function "Get Active Ambulatory Medication Requests" (value List<MedicationRequest>) returns List<MedicationRequest>:
  value Rx
    where Rx.status.value = 'active'
      and exists (
        Rx.category RxCategory
          where FHIRHelpers.ToConcept(RxCategory) ~ "Outpatient"
      )

define function "Is Ambulatory Medication Request?" (value List<MedicationRequest>) returns List<MedicationRequest>:
  value Rx
    where exists (
        Rx.category RxCategory
          where FHIRHelpers.ToConcept(RxCategory) ~ "Outpatient"
      )

define "End of Life Assessment":
    // 1. Conditions indicating end of life or with limited life expectancy
    exists (
      "Conditions Indicating End of Life or With Limited Life Expectancy"
    )
    // 2. Admitted/referred/discharged to hospice care
    or exists (
      "Admitted/Referred/Discharged to Hospice Care"
    )
    // 3. Medications indicating end of life
    /* or exists (
      "Medications Indicating End of Life"
    ) */

define "Conditions Indicating End of Life or With Limited Life Expectancy":
  (
    [Condition: "Conditions likely terminal for opioid prescribing"] C
      where exists (
        C.clinicalStatus.coding Coding
          where FHIRHelpers.ToCode(Coding) ~ "Active Condition"
      )
  )
  union
  (
    [Condition: code in "Limited life expectancy conditions"] C
      where exists (
        C.clinicalStatus.coding Coding
          where FHIRHelpers.ToCode(Coding) ~ "Active Condition"
      )
  )

define "Admitted/Referred/Discharged to Hospice Care":
  (
    [Procedure: code in "Hospice Procedure Codes"] P
      where P.status.value in { 'in-progress', 'completed' }
  )
  union
  (
    [ServiceRequest: code in "Hospice Procedure Codes"] E
      where E.status.value in { 'planned', 'arrived', 'in-progress', 'finished', 'onleave' }
  )
  union
  (
    [Observation: code in "Hospice Finding Codes"] O
      where not (O.status.value in { 'unknown', 'entered-in-error', 'cancelled' })
  )
  union
  (
    [Encounter] E
      where
        (
          if E.hospitalization.dischargeDisposition.coding is null
              or not exists (E.hospitalization.dischargeDisposition.coding)
            then false
          else E.hospitalization.dischargeDisposition in "Hospice Disposition"
        )
        and E.status.value in { 'planned', 'arrived', 'in-progress', 'finished', 'onleave' }
  )

/*

define "Medications Indicating End of Life":
  (
    [MedicationAdministration: "End Of Life Opioids"] MA
      where MA.status.value in { 'in-progress', 'on-hold', 'completed' }
  )
  union
  (
    [MedicationDispense: "End Of Life Opioids"] MD
      where MD.status.value in { 'preparation', 'in-progress', 'on-hold', 'completed' }
  )
  union
  (
    [MedicationRequest: "End Of Life Opioids"] MR
      where MR.status.value in { 'active', 'completed' }
  )
  union
  (
    [MedicationStatement: "End Of Life Opioids"] MS
      where MS.status.value in { 'active', 'completed', 'intended' }
  )

*/


define function Prescriptions(Orders List<MedicationRequest>):
  Orders O
    let
      // NOTE: Assuming medication is specified as a CodeableConcept with a single RxNorm code
      rxNormCode: ToCode(O.medication.coding[0]),
      medicationName: OMTKLogic.GetMedicationName(rxNormCode),
      // NOTE: Assuming a single dosage instruction element
      dosageInstruction: O.dosageInstruction[0],
      // NOTE: Assuming a single dose and rate element
      doseAndRate: dosageInstruction.doseAndRate[0],
      repeat: dosageInstruction.timing.repeat,
      frequency: Coalesce(repeat.frequencyMax.value, repeat.frequency.value),
      period: System.Quantity { value: repeat.period.value, unit: repeat.periodUnit.value },
      doseDescription:
        Coalesce(
          // There should be a conversion from FHIR.SimpleQuantity to System.Quantity
          if doseAndRate.dose is FHIR.Range
            then ToString(ToQuantity(doseAndRate.dose.low))
                          + '-' + ToString(ToQuantity(doseAndRate.dose.high))
                          + doseAndRate.dose.high.unit.value
            else ToString(ToQuantity(doseAndRate.dose)),
            ''
        ),
      frequencyDescription:
        ToString(dosageInstruction.timing.repeat.frequency.value) +
          Coalesce(
            '-' + ToString(dosageInstruction.timing.repeat.frequencyMax.value),
            ''
          )
    return {
      rxNormCode: rxNormCode,
      isDraft: O.status.value = 'draft',
      // NOTE: Assuming asNeeded is expressed as a boolean
      isPRN: dosageInstruction.asNeeded.value,
      prescription:
        if dosageInstruction.text is not null then
          medicationName + ' ' + dosageInstruction.text.value
        else
          // TODO: Shouldn't need the .value here on asNeededBoolean
          medicationName + ' ' + doseDescription + ' q' + frequencyDescription + (if dosageInstruction.asNeeded.value then ' PRN' else ''),
      // TODO: Shouldn't need the ToQuantity here...
      dose: if doseAndRate.dose is FHIR.Range
            then ToQuantity(doseAndRate.dose.high)
            else ToQuantity(doseAndRate.dose),
      dosesPerDay: Coalesce(OMTKLogic.ToDaily(frequency, period), 1.0)
    }

define function MME(prescriptions List<MedicationRequest>):
  (Prescriptions(prescriptions)) P
    let mme: SingletonFrom(OMTKLogic.CalculateMMEs({ { rxNormCode: P.rxNormCode, doseQuantity: P.dose, dosesPerDay: P.dosesPerDay } }))
    return {
      rxNormCode: P.rxNormCode,
      isDraft: P.isDraft,
      isPRN: P.isPRN,
      prescription: P.prescription,
      dailyDose: mme.dailyDoseDescription,
      conversionFactor: mme.conversionFactor,
      mme: mme.mme
    }

define function TotalMME(prescriptions List<MedicationRequest>):
  System.Quantity {
    value: Sum((MME(prescriptions)) M return M.mme.value),
    unit: 'mg/d'
  }

define function ProbableDaysInRange(Orders List<MedicationRequest>, daysPast Integer, numDaysInDaysPast Integer):
  Orders orders
    let
      frequency: orders.dosageInstruction[0].timing.repeat.frequency.value,
      period: orders.dosageInstruction[0].timing.repeat.period.value,
      periodDays: GetPeriodDays(orders.dosageInstruction[0].timing.repeat.periodUnit.value),
      dosesPerDay:
        if (frequency / (period * periodDays)) >= 1.0
        then 1.0
        else frequency / (period * periodDays),
      repeat: orders.dispenseRequest.numberOfRepeatsAllowed.value,
      supplyDuration: GetDurationInDays(orders.dispenseRequest.expectedSupplyDuration),
      validityPeriod: days between orders.dispenseRequest.validityPeriod."start".value and Today(),
      endDifference:
        if orders.dispenseRequest.validityPeriod."end".value < Today()
        then days between orders.dispenseRequest.validityPeriod."end".value and Today()
        else 0
    return
      if (repeat * supplyDuration) < numDaysInDaysPast then false
      else
        (dosesPerDay * ((repeat * supplyDuration) / validityPeriod) * (daysPast - endDifference)) >= numDaysInDaysPast

define function GetPeriodDays(value System.String): // returns Decimal:
  case
    when value = 'a' then 365.0
    when value = 'mo' then 30.0
    when value = 'h' then 1.0/24.0
    when value = 'min' then 1.0/24.0*60.0
    when value = 's' then 1.0/24.0*60.0*60.0
    when value = 'ms' then 1.0/24.0*60.0*60.0*1000.0
    else 1.0
  end

define function GetDurationInDays(value FHIR.Duration): // returns Decimal:
    case
      when StartsWith(value.unit.value, 'a') then value.value.value * 365.0
      when StartsWith(value.unit.value, 'mo') then value.value.value * 30.0
      when StartsWith(value.unit.value, 'wk') then value.value.value * 7.0
      when StartsWith(value.unit.value, 'd') then value.value.value
      when StartsWith(value.unit.value, 'h') then value.value.value / 24.0
      when StartsWith(value.unit.value, 'min') then value.value.value / 60.0 / 24.0
      when StartsWith(value.unit.value, 's') then value.value.value / 60.0 / 60.0 / 24.0
      when StartsWith(value.unit.value, 'ms') then value.value.value / 60.0 / 60.0 / 24.0 / 1000.0
      else Message(1000, true, 'Undefined', 'Error', 'Unsupported duration unit')
    end

define function GetIngredient(rxNormCode Code):
  OMTKLogic.GetIngredients(rxNormCode).ingredientName

define function GetIngredients(rxNormCodes List<Code>):
  rxNormCodes rnc return GetIngredient(rnc)

define function GetMedicationNames(medications List<MedicationRequest>):
  medications M
    return OMTKLogic.GetIngredients(ToRxNormCode(M.medication.coding)).rxNormCode.display

/*
*  Conversion Functions
*/
define function CodeableConceptsToString(concepts List<FHIR.CodeableConcept>):
  concepts c return CodeableConceptToString(c)


define function CodingToString(coding FHIR.Coding):
  if (coding is null)
  then null
  else
    'Code {' &
      'code: ' & coding.code &
      'system: ' & coding.system &
      'version: ' & coding.version &
      'display: ' & coding.display &
    '}'

define function CodeableConceptToString(concept FHIR.CodeableConcept):
  if (concept is null or concept.coding is null)
  then null
  else
    'CodeableConcept {' &
      'Coding: [' &
        Combine(concept.coding Coding return CodingToString(Coding), ',')
      & ']'
    & '}'

define function ToCode(coding FHIR.Coding):
  System.Code {
    code: coding.code.value,
    system: coding.system.value,
    version: coding.version.value,
    display: coding.display.value
  }

define function ToCodes(coding List<FHIR.Coding>):
  coding c return ToCode(c)

define function ToRxNormCode(coding List<FHIR.Coding>):
  singleton from (
    coding C where C.system = 'http://www.nlm.nih.gov/research/umls/rxnorm'
  )

define function ToQuantity(quantity FHIR.Quantity):
  System.Quantity { value: quantity.value.value, unit: quantity.unit.value }
