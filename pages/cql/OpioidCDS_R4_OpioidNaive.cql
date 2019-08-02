library OpioidCDS_R4_OpioidNaive version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common_Config version '0.1.0' called Config
include OpioidCDS_R4_Common version '0.1.0' called Common

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
define "Prescription Inclusion Period":
    Interval[Today() - 91 days, Today()]

define "Report Inclusion Period":
    Interval[Today() - 91 days, Today() - 1 days]

define "Dispensing Event Inclusion Period":
    Interval[Today() - 91 days, Today()]

define "Is Opioid Naive":
    "Prescription Criteria Satsified"
        and "Report Criteria Satisfied"
        and "Dispense Criteria Satisfied"

define "Prescriptions in Past 90 Days Including Today for Opioid with Ambulatory Abuse Potential":
    Common."Active Ambulatory Opioid Rx" orders
        where date from orders.authoredOn.value in day of "Prescription Inclusion Period"

define "Has Prescription in Past 90 Days Including Today for Opioid with Ambulatory Abuse Potential":
    exists ("Prescriptions in Past 90 Days Including Today for Opioid with Ambulatory Abuse Potential")

define "Prescription Criteria Satsified":
    not Config."Opioid Naive Prescription Condition Is Enabled"
        or "Has Prescription in Past 90 Days Including Today for Opioid with Ambulatory Abuse Potential"

define "Reports of Opioid with ambulatory care abuse potential reported in past 90 days":
    [MedicationStatement] Statements

define "Has Report of Opioid with ambulatory care abuse potential reported in past 90 days":
    exists ("Reports of Opioid with ambulatory care abuse potential reported in past 90 days")

define "Report Criteria Satisfied":
    not Config."Opioid Naive Report Condition Is Enabled"
        or "Has Report of Opioid with ambulatory care abuse potential reported in past 90 days"

define "Dispense in Past 90 Days Including Today of Opioid with ambulatory care abuse potential":
    [MedicationDispense] Dispenses

define "Has Dispense in Past 90 Days Including Today of Opioid with ambulatory care abuse potential":
    exists ("Dispense in Past 90 Days Including Today of Opioid with ambulatory care abuse potential")

define "Dispense Criteria Satisfied":
    not Config."Opioid Naive Dispense Condition Is Enabled"
        or "Has Dispense in Past 90 Days Including Today of Opioid with ambulatory care abuse potential"
