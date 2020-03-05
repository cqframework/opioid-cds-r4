library OpioidCDS_ActiveCancerTreatment version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_Common version '0.1.0' called Common
include OpioidCDS_Common_Config version '0.1.0' called Config

/*
**  Opioid Naive subroutine
*/

context Patient

/*
    Two Encounters within 12 months with any diagnosis of Cancer
*/

define "Encounter Period":
  Interval[Now() - 12 months, Now())

define "Active Cancer Treatment":
  Config."Active Cancer Treatment Encounters Condition Is Enabled"
    and "Has Two or More Encounters with Cancer Diagnosis During Encounter Period"

define "Active Cancer Diagnoses":
  [Condition: Common."CDC Malignant Cancer Conditions"]

define "Oncologist Practitioner Roles":
  [PractitionerRole] PractitionerRole
    where exists (
      PractitionerRole.specialty Specialty
        where Specialty in Common."Oncology Specialty Designations (NUCC)"
    )

define "Encounters with Cancer Diagnosis During Encounter Period":
  [Encounter: Common."Office Visit"] Encounter
    where date from Encounter.period."start".value in day of "Encounter Period"
      and exists (
        Encounter.diagnosis EncounterDiagnosis
          with "Active Cancer Diagnoses" CancerDiagnosis
          such that EndsWith(EncounterDiagnosis.condition.reference, CancerDiagnosis.id)
      )
      and exists (
        Encounter.participant EncounterParticipant
          where EncounterParticipant.type in Common."Oncology Specialty Designations (NUCC)"
            or exists (
              "Oncologist Practitioner Roles" PractitionerRole
                where EndsWith(EncounterParticipant.individual.reference, PractitionerRole.id)
            )
      )

define "Number of Enounters with Cancer Diagnosis During Encounter Period":
  Count ("Encounters with Cancer Diagnosis During Encounter Period")

define "Has Two or More Encounters with Cancer Diagnosis During Encounter Period":
  "Number of Enounters with Cancer Diagnosis During Encounter Period" >= 2
