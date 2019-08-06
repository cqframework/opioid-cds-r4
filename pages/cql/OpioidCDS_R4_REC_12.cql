library OpioidCDS_R4_REC_12 version '0.1.0'

using FHIR version '4.0.0'

include FHIRHelpers version '4.0.0' called FHIRHelpers
include OpioidCDS_R4_Common version '0.1.0' called Common
include OpioidCDS_R4_Common_Config version '0.1.0' called Config

/*
**
**  Recommendation #12
**    Clinicians should offer or arrange evidence-based treatment (usually
**    medication-assisted treatment with buprenorphine or methadone in combination
**    with behavioral therapies) for patients with opioid use disorder
**    (recommendation category: A, evidence type: 2).
**
*/

/*

  Plan Definition:
	http://build.fhir.org/ig/cqframework/opioid-cds/stu4/PlanDefinition-opioidcds-12.html
*/


context Patient

define "Trigger Event Prescriptions":
  ContextPrescriptions triggerScripts
      where true //TODO

define "Validate Trigger Event":
  exists( "Trigger Event Prescriptions" )

define "Inclusion Criteria":
  AgeInYears() >= 18
    and "Validate Trigger Event"
    and not "Exclusion Criteria"

define "Exclusion Criteria":
  false

define "Get Indicator":
  if "Inclusion Criteria"
    then 'warning'
  else null

define "Get Summary":
  if "Inclusion Criteria"
    then 'Recommend opioid agonist or partial agonist treatment with methadone maintenance therapy or buprenorphine and/or behavioral therapy.'
  else null

define "Get Detail":
  if "Inclusion Criteria"
    then 'blah'
  else null
