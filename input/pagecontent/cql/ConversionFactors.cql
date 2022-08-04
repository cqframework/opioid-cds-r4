library ConversionFactors version '3.0.0'

/*
This library provides logic to determine the appropriate conversion factor to be
used for calculating Morphine Milligram Equivalent (MME) for a given medication.

The conversion factors are configurable using a CodeSystem supplement. This
implementation guide contains one conversion factor table:

CDCMMEClinicalConversionFactors

The Clinical Conversion Factors table uses values from CDC guidance here:
https://www.cdc.gov/drugoverdose/pdf/calculating_total_daily_dose-a.pdf

The CodeSystem supplements are configured with 3 types of properties:

* conversion-factor: Defines the conversion factor for a specific ingredient,
when the conversion factor is the same for all dose forms and dose amounts for
the ingredient. The value of this property will be the decimal representation of
the conversion factor.
* dose-form-conversion-factor: Defines the conversion factor for an ingredient
when the conversion factor varies by the dose form of the medication. The value
of this property will be a string of the form
<dose-form-code>:<conversion-factor>[@<doses-per-day>],
e.g. 970789:130, where '970789' is the RxNorm dose form code, and '130' is the
decimal representation of the conversion factor. An example of a per-day
conversion factor is fentanyl, 316987:7200@0.33333333, where 316987 is RxNorm
dose form code, 7200 is the conversion factor, and 0.33333333 is the dosesPerDay,
expressed as a decimal with a maximum of 8 digits after the decimal.
* dose-range-conversion-factor: Defines the conversion factor for an ingredient
when the conversion factor varies by the overall dose of the medication. The
value of this property will be a string of the form
<low-value>-<high-value>:<conversion-factor>,
e.g. 1-20:4. Note that the low-value or high-value may be a wildcard '*' to
indicate the range continues (e.g. '61-*:12' indicates the range is 61 or greater).

For a given ingredient, only one of 'dose-form' or 'dose-range' will be present,
with or without an ingredient-specific conversion factor. The properties together
will enable a unique conversion factor to be determined if the input is within
the expected range. If the input is outside the expected range, and there is no
ingredient-specific conversion-factor specified, implementations should indicate
a conversion factor could not be determined from the supplied information.
All conversion factors supplied in these supplements are in 'mg/d'.
*/

using FHIR version '4.0.1'

include FHIRHelpers version '4.0.1'
include CDCMMEClinicalConversionFactors version '3.0.0' called CDCMMEClinicalConversionFactors

codesystem "Usage Context Type": 'http://terminology.hl7.org/CodeSystem/usage-context-type'
codesystem "CDC MME Usage Context Codes": 'http://fhir.org/guides/cdc/opioid-mme-r4/CodeSystem/CDCMMEUsageContextCodes'

code "Task Usage Context": 'task' from "Usage Context Type"
code "MME Calculation": 'mme-calculation' from "CDC MME Usage Context Codes"

parameter ErrorLevel String default 'Trace'

/*
If this parameter is supplied, it specifies the name of the code system supplement
to be used to supply conversion factors for the calculator. If this parameter is not
provided, the _single_ CodeSystem with a task usage context code of "mme-calculation"
from the CDCMMEUsageContextCodes code system will be used to provide conversion factors.
If neither of these configurations is available, the hard-coded conversion factors
in GetConversionFactor will be used. The hard-coded conversion factors use the
clinical conversion factors only.
*/
parameter ConversionFactorSupplementName String default 'CDCMMEClinicalConversionFactors'

context Patient

/*
Returns the conversion factor for the given ingredient

CDC Guidance:
https://www.cdc.gov/drugoverdose/pdf/calculating_total_daily_dose-a.pdf

|Opioid (strength in mg except where noted)     |MME Conversion Factor*|
|-----------------------------------------------|----------------------|
|Codeine                                        |                 0.15 |
|Fentanyl, transdermal patch (MCG/HR)           |                 2.4  |
|Hydrocodone                                    |                 1    |
|Hydromorphone                                  |                 4    |
|Methadone                                      |                      |
|  1-20 mg/d                                    |                 4    |
|  21-40 mg/d                                   |                 8    |
|  41-60 mg/d                                   |                10    |
|  61-80+ mg/d                                  |                12    |
| Morphine                                      |                 1    |
| Oxycodone                                     |                 1.5  |
| Oxymorphone                                   |                 3    |

*/
define function GetConversionFactor(ingredientCode System.Code, dailyDose System.Quantity, doseFormCode System.Code, dosesPerDay System.Decimal):
  Coalesce(
    LookupConversionFactor(ingredientCode, dailyDose, doseFormCode, dosesPerDay),
    case ToInteger(ingredientCode.code)
      when 2670 then 0.15 /*	Codeine */
      when 4337 then ( /*	Fentanyl */
        case
          when ToInteger(doseFormCode.code) = 316987 then (0.33333333 / dosesPerDay) * 7200 /* Transdermal system */
          else Message(null, true, 'OMTKLogic.GetConversionFactor.UnknownDoseForm', ErrorLevel, 'Unknown dose form code ' & doseFormCode.code)
        end
      )
      when 5489 then 1 /*	Hydrocodone */
      when 3423 then 4 /*	Hydromorphone */
      when 6813 then ( /*	Methadone */
        case
          when dailyDose.value between 1 and 20 then 4
          when dailyDose.value between 21 and 40 then 8
          when dailyDose.value between 41 and 60 then 10
          when dailyDose.value >= 61 then 12
          when dailyDose is null or dailyDose.value is null then
            Message(null, true, 'OMTKLogic.GetConversionFactor.DailyDoseNull', ErrorLevel, 'Daily dose is required to determine methadone conversion factor')
          else Message(null, dailyDose.value < 1, 'OMTKLogic.GetConversionFactor.DailyDoseLessThanOne', ErrorLevel, 'Daily dose less than 1')
        end
      )
      when 7052 then 1 /*	Morphine */
      when 7804 then 1.5 /*	Oxycodone */
      when 7814 then 3 /*	Oxymorphone */
      else Message(null, true, 'OMTKLogic.GetConversionFactor.UnknownIngredientCode', ErrorLevel, 'Unknown ingredient code: ' & ingredientCode.code)
    end
  )

define ConversionFactorSupplement:
  CDCMMEClinicalConversionFactors."CDCMMEClinicalConversionFactorsCodeSystem" C
    where C.supplements.value = 'http://www.nlm.nih.gov/research/umls/rxnorm'
    and (
      C.name.value = ConversionFactorSupplementName
        or exists (
          C.useContext UC
            where UC.code ~ "Task Usage Context"
              and UC.value ~ "MME Calculation"
        )
    )

/*
Converts a range value boundary to a Decimal (or null for a wildcard)
*/
define function ToRangeValue(value System.String):
  if value = '*' then null else ToDecimal(value)

/*
Converts the property value of a dose-range-conversion-factor property to the dose range
<low-value>-<high-value>:<conversion-factor>
Note that low-value and/or high-value may be wildcards '*'
*/
define function ToDoseRange(propertyValue FHIR.string):
  ({ : }) X
    let rangeValues: Split(Split(propertyValue.value, ':')[0], '-')
    return Interval[ToRangeValue(rangeValues[0]), ToRangeValue(rangeValues[1])]

/*
Converts the property value of a dose-range-conversion-factor property to the conversion factor
<low-value>-<high-value>:<conversion-factor>
*/
define function ToDoseRangeConversionFactor(propertyValue FHIR.string):
  ToDecimal(Split(propertyValue.value, ':')[1])

/*
Converts the property value of a dose-form-conversion-factor property to the dose form
<dose-form-code>:<conversion-factor>
*/
define function ToDoseForm(propertyValue FHIR.string):
  Split(propertyValue.value, ':')[0]

/*
Converts the property value of a dose-form-conversion-factor property to the conversion factor
<dose-form-code>:<conversion-factor>[@doses-per-day]
*/
define function ToDoseFormConversionFactor(propertyValue FHIR.string, dosesPerDay System.Decimal):
  if PositionOf('@', propertyValue.value) > 0 then
    ToDoseFormDosesPerDayConversionFactor(propertyValue, dosesPerDay)
  else
    ToDecimal(Split(propertyValue.value, ':')[1])

/*
Converts the property value of a dose-form-conversion-factor property to the conversion factor
if the property includes a doses-per-day value
*/
define function ToDoseFormDosesPerDayConversionFactor(propertyValue FHIR.string, dosesPerDay System.Decimal):
  propertyValue P
    let components: Split(P.value, '@')
    return (ToDecimal(components[1]) / dosesPerDay) * ToDecimal(Split(components[0], ':')[1])

/*
Returns the conversion factor for a conversion-factor property
NOTE: These functions are used to avoid use of _is_ and _as_
*/
define function ToConversionFactor(propertyValue FHIR.decimal):
  propertyValue.value

/*
Looks up the conversion factor for the given ingredient, daily dose, and dose form from the
configured conversion factor supplement, if available.

If no conversion factor supplement is configured, returns null
*/
define function LookupConversionFactor(ingredientCode System.Code, dailyDose System.Quantity, doseFormCode System.Code, dosesPerDay System.Decimal):
  ConversionFactorSupplement CFS
    let
      ingredientConcept: singleton from (CFS."concept" C where C.code.value = ingredientCode.code),
      conversionFactor: singleton from (ingredientConcept.property P where P.code.value = 'conversion-factor'),
      doseFormConversionFactors: (ingredientConcept.property P where P.code.value = 'dose-form-conversion-factor'),
      doseRangeConversionFactors: (ingredientConcept.property P where P.code.value = 'dose-range-conversion-factor')
    return
      Coalesce
      (
        case
          when exists (doseRangeConversionFactors) then
            singleton from (
              doseRangeConversionFactors DRCF
                where dailyDose.value in ToDoseRange(DRCF.value)
                return ToDoseRangeConversionFactor(DRCF.value)
            )
          when exists (doseFormConversionFactors) then
            singleton from (
              doseFormConversionFactors DFCF
                where doseFormCode.code = ToDoseForm(DFCF.value)
                return ToDoseFormConversionFactor(DFCF.value, dosesPerDay)
            )
          else null
        end,
        ToConversionFactor(conversionFactor.value)
      )