library OpioidCDS_R4_OpioidNaive version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_Common_Config version '0.1.0' called Config

/*
**  Opioid Naive subroutine
*/

/*
  Plan Definition: http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-opioidnaive.html
*/


context Patient

/*
    Opioid with ambulatory care abuse potential prescription found in past 90 days including today
    Opioid with ambulatory care abuse potential reported in past 90 days
    Opioid with ambulatory care abuse potential dispensing event found in past 90 days including today
*/
define "Prescription/Dispense Inclusion Period":
    Interval[Today() - 89 days, Today()]

define "Report Inclusion Period":
    Interval[Today() - 90 days, Today())

define "Is Opioid Naive":
    "Prescription Criteria Satisfied"
        and "Report Criteria Satisfied"
        and "Dispense Criteria Satisfied"

define "Prescription Criteria Satisfied":
    not (Config."Opioid Naive Prescription Condition Is Enabled"
        or "Has Opioid RX With Ambulatory Abuse Potential In Past 90 Days"
    )

define "Opioid RX With Ambulatory Abuse Potential In Past 90 Days":
[MedicationRequest: Common."Ambulatory Abuse Potential Opioids"] Rx
  where Rx.status.value = 'active'
    and exists (Rx.category.coding Coding
      where Coding.code = 'outpatient'
    )
        and Rx.authoredOn during day of "Prescription/Dispense Inclusion Period"

define "Has Opioid RX With Ambulatory Abuse Potential In Past 90 Days":
    exists ("Opioid RX With Ambulatory Abuse Potential In Past 90 Days")


    define "Report Criteria Satisfied":
        not (Config."Opioid Naive Report Condition Is Enabled
            or "Has Report of Opioid with ambulatory care abuse potential reported in past 90 days"
        )

define "Reports of Opioid with ambulatory care abuse potential reported in past 90 days":
    [MedicationStatement: "Ambulatory Abuse Potential Opioids"] Statement
      where Statement.status in {'active', 'completed'}
        and Statement.effective as dateTime during day of "Report Inclusion Period"

define "Has Report of Opioid with ambulatory care abuse potential reported in past 90 days":
    exists ("Reports of Opioid with ambulatory care abuse potential reported in past 90 days")


    define "Dispense Criteria Satisfied":
        not (Config."Opioid Naive Dispense Condition Is Enabled"
            or "Has Opioid Dispense With Ambulatory Abuse Potential In Past 90 Days"
        )
define "Opioid Dispense With Ambulatory Abuse Potential In Past 90 Days":
    [MedicationDispense: "Ambulatory Abuse Potential Opioids"] OpioidDispense
      where OpioidDispense.whenHandedOver during day of "Prescription/Dispense Inclusion Period"
        and OpioidDispense.status = 'completed'

define "Has Opioid Dispense With Ambulatory Abuse Potential In Past 90 Days":
    exists ("Opioid Dispense With Ambulatory Abuse Potential In Past 90 Days")
