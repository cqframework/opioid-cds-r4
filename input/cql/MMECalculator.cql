library MMECalculator version '3.0.0'

/*
This library contains logic to surface the MME calculation functionality provided
by the OMTKLogic library by extracting appropriate information from FHIR R4
MedicationRequest resource.
*/

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include OMTKLogic version '3.0.0'

parameter ErrorLevel String default 'Warning'

context Patient

/*
Helper function to force the choice of the FHIR.Range value.
This avoids the need for the _is_ and _as_ operators on choices,
which is not implemented in the JavaScript CQL engine.
*/
define function ToFHIRRange(range FHIR.Range):
  range

/*
Helper function to force the choice of the FHIR.SimpleQuantity value.
This avoids the need for the _is_ and _as_ operators on choices,
which is not implemented in the JavaScript CQL engine.
*/
define function ToFHIRQuantity(quantity FHIR.SimpleQuantity):
  quantity

/*
Helper function to force the choice of the FHIR.CodeableConcept value.
This avoids the need for the _is_ and _as_ operators on choices,
which is not implemented in the JavaScript CQL engine.
*/
define function ToFHIRCodeableConcept(codeableConcept FHIR.CodeableConcept):
  codeableConcept

/*
FHIRHelpers ToQuantity logic incorrectly uses the unit element of the FHIR Quantity,
when it should be using the code element as the actual coded unit.
https://github.com/cqframework/clinical_quality_language/issues/557

Until the above issue is addressed, this function provides ToQuantity functionality for this library
*/
define function ToQuantity(quantity FHIR.SimpleQuantity):
  case
    when quantity is null then null
    when quantity.value is null then null
    when quantity.system is null or quantity.system = 'http://unitsofmeasure.org' then
      System.Quantity {
        value: quantity.value.value,
        unit: quantity.code.value
      }
   when quantity.system.value = 'http://terminology.hl7.org/CodeSystem/v3-orderableDrugForm' then
    System.Quantity { value: quantity.value.value, unit: Coalesce(quantity.code.value, quantity.unit.value)}
   else
      Message(null, true, 'MMECalculator.ToQuantity.InvalidFHIRQuantity', ErrorLevel, 'Invalid FHIR Quantity code: ' & quantity.code.value)
end

/*
Extracts the relevant information for prescription calculation from a list of
FHIR MedicationRequest resources. This assumes a MedicationRequest that conforms
to the MMEMedicationRequest profile, specifically:
* 1 and only 1 dosageInstruction
* 1 and only 1 doseAndRate
* 1 timing with 1 repeat
* frequency, frequencyMax, defaulting to 1
* period, periodUnit, defaulting to 1 'd'
* doseQuantity or doseRange
* timeOfDay

Note that if timeOfDay is specified in addition to frequency and period, it is ignored (i.e. assumed to be consistent with the specified frequency and period).
TimeOfDay is only used to determine timesPerDay if frequency and period are not specified.
*/
define function Prescriptions(Orders List<MedicationRequest>):
  Orders O
    let
      rxNormCode: OMTKLogic.GetMedicationCode(O.medication),
      medicationName: OMTKLogic.GetMedicationName(rxNormCode),
      // NOTE: Assuming a single dosage instruction element
      dosageInstruction: singleton from O.dosageInstruction,
      //  NOTE: Some systems return multiple doseAndRate entries, with system-specific codes for the types. In those cases,
      //  this logic should select the most appropriate dose and rate, but standardization on doseAndRate type codes is
      //  needed to make this logic shareable
      doseAndRate: singleton from (dosageInstruction.doseAndRate DR where DR.type is null or DR.type.text = 'ordered'),
      repeat: dosageInstruction.timing.repeat,
      frequency: Coalesce(repeat.frequencyMax.value, repeat.frequency.value),
      period: OMTKLogic.Quantity(repeat.period.value, repeat.periodUnit.value),
      doseRange: ToFHIRRange(doseAndRate.dose),
      doseQuantity: ToFHIRQuantity(doseAndRate.dose),
      doseHigh: ToQuantity(doseRange.high as FHIR.SimpleQuantity),
      timesPerDay: Count(repeat.timeOfDay),
      doseDescription:
        Coalesce(
          ToString(ToQuantity(doseQuantity)),
          ToString(doseRange.low.value.value) + '-' + ToString(doseRange.high.value.value) + ' ' + doseRange.high.unit.value
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
      isPRN: dosageInstruction.asNeeded,
      prescription:
        if dosageInstruction.text is not null then
          medicationName + ' ' + dosageInstruction.text.value
        else
          // TODO: Shouldn't need the .value here on asNeededBoolean
          medicationName + ' ' + doseDescription + ' q' + frequencyDescription + (if dosageInstruction.asNeeded then ' PRN' else ''),
     dose:
        if doseAndRate.dose is not null then
            ToQuantity(doseQuantity)
        else
            doseHigh,
      dosesPerDay: Coalesce(OMTKLogic.ToDaily(frequency, period), timesPerDay, 1.0)
    }

/*
Calculates Morphine Milligram Equivalent (MME) for each medication in the given
list. The calculation assumes the most aggresive dosing, and is performed for all
medications in the given list (i.e. no additional filtering for status is performed).
*/
define function MME(prescriptions List<MedicationRequest>):
  (Prescriptions(prescriptions)) P
    let mmePerIngredient: OMTKLogic.CalculateMMEs({ { rxNormCode: P.rxNormCode, doseQuantity: P.dose, dosesPerDay: P.dosesPerDay } })
    return {
      rxNormCode: P.rxNormCode,
      isDraft: P.isDraft,
      isPRN: P.isPRN,
      prescription: P.prescription,
      dailyDose: Combine(mmePerIngredient X return X.dailyDoseDescription, '\r\n'),
      mme: Sum(mmePerIngredient X return X.mme)
    }

/*
Calculates total Morphine Milligram Equivalent (MME) for the given list of medications.
The calculation assumes the most aggressive dosing, and is performed for all
medications in the given list (i.e. no additional filtering for status is performed).
*/
define function TotalMME(prescriptions List<MedicationRequest>):
  OMTKLogic.Quantity(
    Sum((MME(prescriptions)) M return M.mme.value),
    '{MME}/d'
  )