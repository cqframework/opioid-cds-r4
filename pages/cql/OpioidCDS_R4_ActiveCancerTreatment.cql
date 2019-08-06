library OpioidCDS_R4_ActiveCancerTreatment version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_Common_Config version '0.1.0' called Config

/*
**  Opioid Naive subroutine
*/

/*
  Plan Definition: http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-activecancertreatment.html
*/


context Patient

/*
    Two Encounters within 12 months with any diagnosis of Cancer
*/

define "Encounter Period":
  Interval[Now() - 12 months, Now())

define "Active Cancer Treatment":
  Config."Active Cancer Treatment-Encounters Condition Is Enabled"
    and "Has Two or More Encounters with Cancer Diagnosis During Encounter Period"

define "Encounters with Cancer Diagnosis During Encounter Period":
  [Encounter: Common."All Ambulatory Encounters"] encounters
    where date from encounters.period."start".value in day of "Encounter Period"

define "Number of Enounters with Cancer Diagnosis During Encounter Period":
  Count ("Encounters with Cancer Diagnosis During Encounter Period")

define "Has Two or More Encounters with Cancer Diagnosis During Encounter Period":
  "Number of Enounters with Cancer Diagnosis During Encounter Period" >= 2
