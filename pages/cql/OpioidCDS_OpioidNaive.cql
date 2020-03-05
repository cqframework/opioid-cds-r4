library OpioidCDS_OpioidNaive version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common
include OpioidCDS_Common_Config version '0.1.0' called Config

/*
**  Opioid Naive subroutine
*/

context Patient

/*
    Opioid with ambulatory care abuse potential prescription found in past 90 days including today
    Opioid with ambulatory care abuse potential reported in past 90 days
    Opioid with ambulatory care abuse potential dispensing event found in past 90 days including today
*/
define "Prescription/Dispense Inclusion Period":
    Interval[Now() - 89 days, Now()]

define "Report Inclusion Period":
    Interval[Now() - 90 days, Now())

define "Is Opioid Naive":
    not ("Has Opioid RX with Ambulatory Abuse Potential In Past 90 Days")
    and not ("Has Report of Opioid with Ambulatory Care Abuse Potential Reported in Past 90 Days")
    and not ("Has Opioid Dispense with Ambulatory Abuse Potential In Past 90 Days")

define "Opioid RX with Ambulatory Abuse Potential In Past 90 Days":
  Common."Active Ambulatory Opioid Rx" Rx
      where FHIRHelpers.ToDateTime(Rx.authoredOn) during day of "Prescription/Dispense Inclusion Period"

define "Has Opioid RX with Ambulatory Abuse Potential In Past 90 Days":
    Config."Opioid Naive Prescription Condition Is Enabled"
        and exists ("Opioid RX with Ambulatory Abuse Potential In Past 90 Days")

// NOTE: 2020-02-05: Review direction of MedicationStatement resource (US-Core focusing on MedicationRequest i/o Statement)
define "Reports of Opioid with Ambulatory Care Abuse Potential Reported in Past 90 Days":
    [MedicationStatement: Common."Opioid analgesics with ambulatory misuse potential"] Statement
        where Statement.status in {'active', 'completed'}
            and FHIRHelpers.ToDateTime(Statement.effective as dateTime) during day of "Report Inclusion Period"

define "Has Report of Opioid with Ambulatory Care Abuse Potential Reported in Past 90 Days":
    Config."Opioid Naive Report Condition Is Enabled"
        and exists ("Reports of Opioid with Ambulatory Care Abuse Potential Reported in Past 90 Days")

define "Opioid Dispense with Ambulatory Abuse Potential In Past 90 Days":
    [MedicationDispense: Common."Opioid analgesics with ambulatory misuse potential"] OpioidDispense
        where FHIRHelpers.ToDateTime(OpioidDispense.whenHandedOver) during day of "Prescription/Dispense Inclusion Period"
            and OpioidDispense.status = 'completed'

define "Has Opioid Dispense with Ambulatory Abuse Potential In Past 90 Days":
    Config."Opioid Naive Dispense Condition Is Enabled"
        and exists ("Opioid Dispense with Ambulatory Abuse Potential In Past 90 Days")
